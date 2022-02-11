import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import P "mo:base/Prelude";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Http "http";
import Types "types";
actor class HttpDemo() = this{
    //File start
    // Create file
    type FileId = Types.FileId;
    type FileInit = Types.FileInit;
    type UserName = Types.UserName;
    type FileInfo2 = Types.FileInfo2;
    type ChunkData = Types.ChunkData;
    type ChunkId = Types.ChunkId;
    var state = Types.empty();
    private func createFile_(fileData : FileInit, userName: UserName) : ?FileId {
        let now = Time.now();
        let fileId = userName # "-" # fileData.name # "-" # (Int.toText(now));
        switch (state.files2.get(fileId)) {
            case (?_) { /* error -- ID already taken. */ null };
            case null { /* ok, not taken yet. */
                state.files2.put(fileId, {
                    fileId = fileId;
                    userName = userName;
                    name = fileData.name;
                    createdAt = now;
                    chunkCount = fileData.chunkCount;
                    fileSize = fileData.fileSize;
                    mimeType = fileData.mimeType;
                });
                ?fileId
            };
        };
    };

    public shared(msg) func createFile(i : FileInit, userName: UserName) : async ?FileId {
        do?{
            // assert(msg.caller==owner);
            let fileId = createFile_(i, userName);
            fileId!
        }
    };

    // Get all files
    public query(msg) func getFiles() : async ?[FileInfo2] {
        do?{
            // assert(msg.caller==owner);
            let b = Buffer.Buffer<FileInfo2>(0);
            for ((k,v) in state.files2.entries()) {
                b.add(v);
            };
            b.toArray()
        }
    };

    // Mark File
    public shared(msg) func markFile(fileId : FileId) : async ?() {
        do ? {
            // assert(msg.caller==owner);
            var fileInfo = state.files2.get(fileId)!;
            state.files2.put(fileId, {
                userName = fileInfo.userName;
                createdAt = fileInfo.createdAt ;
                fileId = fileId ;
                name = fileInfo.name ;
                chunkCount = fileInfo.chunkCount ;
                fileSize = fileInfo.fileSize;
                mimeType = fileInfo.mimeType ;
                // thumbnail = fileInfo.thumbnail;
                // marked= not(fileInfo.marked) ;
                // sharedWith = fileInfo.sharedWith ;
                // madePublic = fileInfo.madePublic;
                // fileHash = fileInfo.fileHash;
                // folder = fileInfo.folder;
            });
        }
    };

    func chunkId(fileId : FileId, chunkNum : Nat) : ChunkId {
        fileId # (Nat.toText(chunkNum));
    };

    // Put File Chunk
    public shared(msg) func putFileChunk
        (fileId : FileId, chunkNum : Nat, chunkData : ChunkData) : async ()
        {
        // assert(msg.caller==owner);
        Debug.print("chunkNum::::"#Nat.toText(chunkNum));
        state.chunks.put(chunkId(fileId, chunkNum), chunkData);
    };

    // Get File Chunk
    public query(msg) func getFileChunk(fileId : FileId, chunkNum : Nat) : async ?ChunkData {
        // assert(msg.caller==owner);
        state.chunks.get(chunkId(fileId, chunkNum));
    };

    private func getFileChunks({fileId : FileId;chunkCount : Nat}) : [ChunkData] {
        let b = Buffer.Buffer<ChunkData>(0);
        var chunkNum : Nat = 1;
        while(chunkNum <= chunkCount){
            let chunkData = unwrap<ChunkData>(state.chunks.get(chunkId(fileId, chunkNum)));
            b.add(chunkData);
            chunkNum += 1;
        };
        b.toArray();
    };
    
    public shared query({caller}) func http_request(request : Http.HttpRequest) : async Http.HttpResponse {
        Debug.print("url :" # request.url);
        let fileId = request.url;
        switch(state.files2.get(fileId)){
            case(null) {
                return {
                    body = Blob.toArray(Text.encodeUtf8("Not Found."));
                    headers = [];
                    status_code = 404;
                    streaming_strategy = null;
                };
            };
            case (?fileInfo){
                if(fileInfo.fileSize == 1){
                    return {
                        status_code =200;
                        headers = [("Content-Type",fileInfo.mimeType)];
                        body = Blob.toArray(unwrap<ChunkData>(state.chunks.get(chunkId(fileId, 1))));
                        streaming_strategy = null;
                    }
                }else{
                    return {
                        status_code =200;
                        headers = [("Content-Type",fileInfo.mimeType)];
                        body = Blob.toArray(unwrap<ChunkData>(state.chunks.get(chunkId(fileId, 1))));
                        streaming_strategy = createStrategy(fileInfo.fileId,0,getFileChunks(fileInfo));
                    }
                };
            };
        }
    };

    public shared query({caller}) func http_request_streaming_callback(tk: Http.StreamingCallbackToken) : async Http.StreamingCallbackHttpResponse {
        switch (state.files2.get(tk.key)) {
            case (? v)  {
                return {
                    body = Blob.toArray(unwrap<ChunkData>(state.chunks.get(chunkId(tk.key,tk.index))));
                    token = createToken(tk.key, tk.index, getFileChunks(v));
                };
            };
            case (_) {
                throw Error.reject("Streamed asset not found");
            };
        };
    };

    private func createStrategy(key: Text, index: Nat, data: [Blob]) : ?Http.StreamingStrategy {
        let streamingToken: ?Http.StreamingCallbackToken = createToken(key, index, data);
        switch (streamingToken) {
            case (null) { null };
            case (?streamingToken) {
                // Hack: https://forum.dfinity.org/t/cryptic-error-from-icx-proxy/6944/8
                // Issue: https://github.com/dfinity/candid/issues/273

                let self: Principal = Principal.fromActor(this);
                let canisterId: Text = Principal.toText(self);

                let canister = actor (canisterId) : actor { http_request_streaming_callback : shared () -> async () };

                return ?#Callback({
                    token = streamingToken;
                    callback = canister.http_request_streaming_callback;
                });
            };
        };
    };

    private func createToken(key: Text, chunkIndex: Nat, data: [Blob]) : ?Http.StreamingCallbackToken {
        if (chunkIndex + 1 >= data.size()) {
            return null;
        };

        let streamingToken: ?Http.StreamingCallbackToken = ?{
            // fullPath = key.fullPath;
            key = key;
            index = chunkIndex + 1;
            contentEncoding = "gzip";
        };

        return streamingToken;
    };

     private func unwrap<T>(x : ?T) : T =
        switch x {
            case null { P.unreachable() };
            case (?x_) { x_ };
        };

    ///stable
    private stable var chunkArray : [(ChunkId,ChunkData)] = [];
    private stable var fileArray : [(FileId,FileInfo2)] = [];

    system func preupgrade() {
        chunkArray := Iter.toArray(state.chunks.entries());
        fileArray := Iter.toArray(state.files2.entries());
    };

    system func postupgrade(){
        for ((chunkId, chunkData) in chunkArray.vals()) {
            state.chunks.put(chunkId, chunkData);
        };
        for ((fileId, fileInfo) in fileArray.vals()) {
            state.files2.put(fileId, fileInfo);
        };
    };
};

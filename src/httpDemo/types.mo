import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
module {
    public type UserId = Principal;
    public type UserName = Text;
    public type FileId = Text; // chosen by createFile
    public type ChunkId = Text; // FileId # (toText(ChunkNum))
    public type ChunkData = Blob; // encoded as ??
    public type Map<X, Y> = TrieMap.TrieMap<X, Y>;
    public type FileInit = {
        name: Text;
        chunkCount: Nat;
        fileSize: Nat;
        mimeType: Text;
        // thumbnail: Text;
        // marked: Bool;
        // sharedWith: [UserName];
        // folder: Text;
    };

    public type FileInfo = {
        fileId : FileId;
        userId: UserId;
        createdAt : Int;
        name: Text;
        chunkCount: Nat;
        fileSize: Nat;
        mimeType: Text;
        // marked: Bool;
        // sharedWith: [UserName];
        // madePublic: Bool;
        // fileHash: Text;
    };

    public type FileInfo2 = {
        fileId : FileId;
        userId: UserId;
        createdAt : Int;
        name: Text;
        chunkCount: Nat;
        fileSize: Nat;
        mimeType: Text;
        // thumbnail: Text;
        // marked: Bool;
        // sharedWith: [UserName];
        // madePublic: Bool;
        // fileHash: Text;
        // folder: Text;
    };

    public type State = {
        /// all files.
        // files : Map<FileId, FileInfo>;
        /// all chunks.
        chunks : Map<ChunkId, ChunkData>;
        /// all files.
        files2 : Map<FileId, FileInfo2>;
    };

    public func empty () : State {

        let st : State = {
        chunks = TrieMap.TrieMap<ChunkId, ChunkData>(Text.equal, Text.hash);
        // files = TrieMap.TrieMap<FileId, FileInfo>(Text.equal, Text.hash);
        files2 = TrieMap.TrieMap<FileId, FileInfo2>(Text.equal, Text.hash);
        };
        st
    };
}
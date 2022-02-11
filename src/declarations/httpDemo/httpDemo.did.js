export const idlFactory = ({ IDL }) => {
  const FileInit = IDL.Record({
    'name' : IDL.Text,
    'mimeType' : IDL.Text,
    'fileSize' : IDL.Nat,
    'chunkCount' : IDL.Nat,
  });
  const UserName__1 = IDL.Text;
  const FileId = IDL.Text;
  const ChunkData = IDL.Vec(IDL.Nat8);
  const UserName = IDL.Text;
  const FileId__1 = IDL.Text;
  const FileInfo2 = IDL.Record({
    'userName' : UserName,
    'name' : IDL.Text,
    'createdAt' : IDL.Int,
    'mimeType' : IDL.Text,
    'fileSize' : IDL.Nat,
    'fileId' : FileId__1,
    'chunkCount' : IDL.Nat,
  });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const StreamingCallbackToken = IDL.Record({
    'token' : IDL.Text,
    'fullPath' : IDL.Text,
    'index' : IDL.Nat,
    'contentEncoding' : IDL.Text,
  });
  const StreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : IDL.Func([], [], []),
    }),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const StreamingCallbackHttpResponse = IDL.Record({
    'token' : IDL.Opt(StreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const HttpDemo = IDL.Service({
    'createFile' : IDL.Func([FileInit, UserName__1], [IDL.Opt(FileId)], []),
    'getFileChunk' : IDL.Func(
        [FileId, IDL.Nat],
        [IDL.Opt(ChunkData)],
        ['query'],
      ),
    'getFiles' : IDL.Func([], [IDL.Opt(IDL.Vec(FileInfo2))], ['query']),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'http_request_streaming_callback' : IDL.Func(
        [StreamingCallbackToken],
        [StreamingCallbackHttpResponse],
        ['query'],
      ),
    'markFile' : IDL.Func([FileId], [IDL.Opt(IDL.Null)], []),
    'putFileChunk' : IDL.Func([FileId, IDL.Nat, ChunkData], [], []),
  });
  return HttpDemo;
};
export const init = ({ IDL }) => { return []; };

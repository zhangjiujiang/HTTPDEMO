import type { Principal } from '@dfinity/principal';
export type ChunkData = Array<number>;
export type FileId = string;
export type FileId__1 = string;
export interface FileInfo2 {
  'userName' : UserName,
  'name' : string,
  'createdAt' : bigint,
  'mimeType' : string,
  'fileSize' : bigint,
  'fileId' : FileId__1,
  'chunkCount' : bigint,
}
export interface FileInit {
  'name' : string,
  'mimeType' : string,
  'fileSize' : bigint,
  'chunkCount' : bigint,
}
export type HeaderField = [string, string];
export interface HttpDemo {
  'createFile' : (arg_0: FileInit, arg_1: UserName__1) => Promise<
      [] | [FileId]
    >,
  'getFileChunk' : (arg_0: FileId, arg_1: bigint) => Promise<[] | [ChunkData]>,
  'getFiles' : () => Promise<[] | [Array<FileInfo2>]>,
  'http_request' : (arg_0: HttpRequest) => Promise<HttpResponse>,
  'http_request_streaming_callback' : (
      arg_0: StreamingCallbackToken,
    ) => Promise<StreamingCallbackHttpResponse>,
  'markFile' : (arg_0: FileId) => Promise<[] | [null]>,
  'putFileChunk' : (arg_0: FileId, arg_1: bigint, arg_2: ChunkData) => Promise<
      undefined
    >,
}
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
export interface StreamingCallbackHttpResponse {
  'token' : [] | [StreamingCallbackToken],
  'body' : Array<number>,
}
export interface StreamingCallbackToken {
  'token' : string,
  'fullPath' : string,
  'index' : bigint,
  'contentEncoding' : string,
}
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : [Principal, string],
    }
  };
export type UserName = string;
export type UserName__1 = string;
export interface _SERVICE extends HttpDemo {}

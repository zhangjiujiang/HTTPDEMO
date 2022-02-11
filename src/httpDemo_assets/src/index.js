import { httpDemo } from "../../declarations/httpDemo";

const isImage = (mimeType) => {
  let flag = false;
  if (mimeType.indexOf('image') !== -1) {
    flag = true;
  }
  return (flag);
};

async function getFileInit(file) {
  const chunkCount = Number(Math.ceil(file.size / MAX_CHUNK_SIZE));
  console.log("chunkCount::::" + chunkCount);
  if (isImage(file.type)) {
    return {
      chunkCount,
      fileSize: file.size,
      name: file.name,
      mimeType: file.type,
      // marked: false,
      // sharedWith: [],
      // thumbnail: await resizeFile(file),
      // folder,
    };
  }
  return {
    chunkCount,
    fileSize: file.size,
    name: file.name,
    mimeType: file.type,
    // marked: false,
    // sharedWith: [],
    // thumbnail: '',
    // folder,
  };
};

const MAX_CHUNK_SIZE = 1024 * 1024 * 1.5; // 1.5MB

const encodeArrayBuffer = (file) => Array.from(new Uint8Array(file));

document.getElementById('upload-file').addEventListener('change', async (evt) => {
  const file_list = evt.target.files
  const file = file_list[0];
  const fileInit = await getFileInit(file);
  const [fileId] = await httpDemo.createFile(fileInit, "anywn");
  console.log("fileId::::" + fileId);
  let chunk = 1;

  for (
    let byteStart = 0;
    byteStart < file.size;
    byteStart += MAX_CHUNK_SIZE, chunk += 1
  ) {
    const fileSlice = file.slice(byteStart, Math.min(file.size, byteStart + MAX_CHUNK_SIZE), file.type);
    const fileSliceBuffer = (await fileSlice.arrayBuffer()) || new ArrayBuffer(0);
    const sliceToNat = encodeArrayBuffer(fileSliceBuffer);
    await httpDemo.putFileChunk(fileId, chunk, sliceToNat);
  }
  console.log("upload file successed");
});
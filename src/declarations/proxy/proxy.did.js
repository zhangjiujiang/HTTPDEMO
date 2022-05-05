export const idlFactory = ({ IDL }) => {
  const Proxy = IDL.Service({
    'getBucket' : IDL.Func([], [IDL.Principal], []),
  });
  return Proxy;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };

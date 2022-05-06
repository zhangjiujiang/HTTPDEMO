
import Bucket "bucket";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
shared actor class Proxy(owner : Principal) = this {
    private stable var currentBucket : ?Principal = null;
    private stable var maxMemory: Nat = 3900 * 1024 * 1024; //3.8GB
    private var bucketCyclesInit: Nat = 200000000000;
    private func _newBucket() : async Principal {
        Cycles.add(bucketCyclesInit);
        let bucketActor = await Bucket.BucketActor();
        let bucket: Principal = Principal.fromActor(bucketActor);
        currentBucket := ?bucket;
        return bucket;
    };

    private func _getBucket() : async Principal{
        switch (currentBucket){
            case (?_bucket){
                let bucketActor: Bucket.BucketActor = actor(Principal.toText(_bucket));
                let memory : Nat = await bucketActor.getMemory();
                if (memory >= maxMemory){
                    let bucket = await _newBucket();
                    currentBucket := ?bucket;
                    return bucket;
                };
                return _bucket;
            };
            case _ {
                return await _newBucket();
            };
        }
    };

    public shared func getBucket() : async Principal{
        await _getBucket();
    };


    private stable var creator_whitelist : [Principal] = [];
    public shared(msg) func addCreator_whitelist(whitelist : [Principal]) : async () {
        assert(msg.caller == owner);
        creator_whitelist := Array.append(creator_whitelist,whitelist);
    };

    public shared(msg) func delCreator_whitelist(whitelists : [Principal]) : async () {
        assert(msg.caller == owner);
        for(whitelist in whitelists.vals()) {
            creator_whitelist := Array.filter<Principal>(creator_whitelist,func(v){v != whitelist});
        };
    };

    public query(msg) func getCreator_whitelist() : async [Principal] {
        creator_whitelist
    };
    // assert(Utils.existIm<Principal>(creator_whitelist,func(v){v == msg.caller}));
    private stable var applylist : [Blob] = [];
    
    public shared(msg) func apply(apply : Blob) : async Bool {
        assert(exist<Principal>(creator_whitelist,func(v){v == msg.caller}));
        applylist := Array.append<Blob>(applylist,Array.make(apply));
        true;
    };

    public shared(msg) func clearApply() : async Bool {
        assert(exist<Principal>(creator_whitelist,func(v){v == msg.caller}));
        applylist := [];
        true;
    };

    public shared(msg) func delApply(apply : Blob) : async Bool {
        assert(exist<Principal>(creator_whitelist,func(v){v == msg.caller}));
        applylist := Array.filter<Blob>(applylist,func(v){v != apply});
        true;
    };

    func exist<T>(xs:[T],f : T -> Bool) : Bool{
        for (x in xs.vals()) {
            if(f(x)){
                return true;
            };
        };
        return false;
    };
}
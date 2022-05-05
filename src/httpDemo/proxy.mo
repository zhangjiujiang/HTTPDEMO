
import Bucket "bucket";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
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
}
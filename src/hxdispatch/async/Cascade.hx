package hxdispatch.async;

#if !js
    import hxdispatch.concurrent.Future;
#end
import hxdispatch.Cascade.Tier;
import hxdispatch.async.Executor;

/**
 * This Cascade implementation is a thread-safe, asynchronous implementation.
 *
 * Each Tier is executed by the asynchronous Executor.
 *
 * @{inherit}
 */
class Cascade<T> extends hxdispatch.concurrent.Cascade<T>
{
    /**
     * Stores the Executor used to process the Tiers.
     *
     * @var hxdispatch.async.Executor<T>
     */
    private var executor:Executor<T>;


    /**
     * @param hxdispatch.async.Executor<T> the Tier Executor to use
     *
     * @{inherit}
     */
    public function new(executor:Executor<T>):Void
    {
        super();
        this.executor = executor;
    }

    /**
     * Asynchronous descends all the Tiers.
     *
     * @param T arg the argument to pass to the first Tier
     *
     * @return Future<T> a Future that will get resolved by the last Tier
     */
    #if !js
        public function plunge(arg:T):Future<T>
        {
            this.mutex.acquire();
            var tiers:Array<Tier<T>> = Lambda.array(this.tiers);
            this.mutex.release();

            var future:Future<T> = new Future<T>();
            this.executor.execute(function(arg:T):Void {
                var tier:Tier<T>;
                for (tier in tiers) {
                    arg = tier(arg);
                }
                future.resolve(arg);
            }, arg);

            return future;
        }
    #else
        public function plunge(arg:T):Void
        {
            var tiers:Array<Tier<T>> = Lambda.array(this.tiers);
            this.executor.execute(function(arg:T):Void {
                var tier:Tier<T>;
                for (tier in tiers) {
                    arg = tier(arg);
                }
            }, arg);
        }
    #end
}

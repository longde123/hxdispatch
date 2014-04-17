package hxdispatch.async;

#if cpp
    import cpp.vm.Lock;
    import cpp.vm.Mutex;
#elseif java
    import java.vm.Lock;
    import java.vm.Mutex;
#elseif neko
    import neko.vm.Lock;
    import neko.vm.Mutex;
#elseif !js
    #error "Async Promise is not supported on target platform due to the lack of Lock/Mutex feature."
#end

/**
 *
 */
class Promise<T> extends hxdispatch.concurrent.Promise<T>
{
    /**
     * Stores the Executor used to process Callbacks.
     *
     * @var hxdispatch.async.Executor<T>
     */
    private var executor:Executor<T>;

    /**
     * Stores the Lock used to block await() callers.
     *
     * @var Lock
     */
    #if !js private var lock:Lock; #end

    /**
     * Stores the number of waiters.
     *
     * @var Int
     */
    private var waiters:Int;


    /**
     * @param hxdispatch.async.Executor<T> the Callback Executor to use
     *
     * @{inherit}
     */
    public function new(executor:Executor<T>, ?resolves:Int = 1):Void
    {
        super(resolves);
        this.executor     = executor;
        #if !js this.lock = new Lock(); #end
        this.waiters      = 0;
    }

    /**
     * Blocks the calling Thread until the Promise has been marked as done
     * and Callbacks have been processed.
     */
    #if !js
        public function await():Void
        {
            if (!this.isDone()) {
                this.mutex.waiters.acquire();
                ++this.waiters;
                this.mutex.waiters.release();

                this.lock.wait();
            }
        }
    #end

    /**
     * @{inherit}
     */
    override private function executeCallbacks(callbacks:Iterable<Callback<T>>, arg:T):Void
    {
        var count:Int;
        if ((count = Lambda.count(callbacks)) == 0) {
            #if !js this.unlock(); #end
        } else {
            #if !js var mutex:Mutex = new Mutex(); #end
            var callback:Callback<T>;
            for (callback in callbacks) {
                this.executor.execute(function(arg:T):Void {
                    try {
                        callback(arg);
                    } catch (ex:Dynamic) {}

                    #if !js mutex.acquire();
                    if (--count == 0) {
                        this.unlock();
                    }
                    mutex.release(); #end
                }, arg);
            }
        }
    }

    /**
     * Unlocks the Lock that is used to block waiters in await() method.
     */
    #if !js
        private function unlock():Void
        {
            this.mutex.waiters.acquire();
            for (i in 0...this.waiters) {
                this.lock.release();
            }
            this.waiters = 0;
            this.mutex.waiters.release();
        }
    #end
}

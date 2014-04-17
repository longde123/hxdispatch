package hxdispatch.tests;

/**
 * TestSuite for the hxdispatch.Promise class.
 *
 * TODO: static when() method
 */
class TestPromise extends haxe.unit.TestCase
{
    /**
     * Stores the Promise on which the tests are run.
     *
     * @var hxdispatch.Promise<Int>
     */
    private var promise:hxdispatch.Promise<Int>;


    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.promise = new hxdispatch.Promise<Int>();
    }

    /**
     *@{inherit}
     */
    override public function tearDown():Void
    {
        this.promise = null;
    }


    /**
     * Checks if the done() Callbacks are executed when the Promise gets rejected.
     *
     * Attn: This test depends on the reject() method - make sure all tests for that
     * method work before looking for errors in reject() when this test fails.
     */
    public function testDoneWhenRejected():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.done(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.reject(input);
        assertTrue(executed);
    }

    /**
     * Checks if the done() Callbacks are executed when the Promise gets resolved.
     *
     * Attn: This test depends on the resolve() method - make sure all tests for that
     * method work before looking for errors in resolve() when this test fails.
     */
    public function testDoneWhenResolved():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.done(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.resolve(input);
        assertTrue(executed);
    }

    /**
     * Checks if the done() method throws an Exception when trying to add Callbacks
     * after the Promise has been marked as done.
     *
     * Attn: This test depends on the resolve() method - make sure all tests for that
     * method work before looking for errors in resolve() when this test fails.
     */
    public function testDoneThrowsWorkflowException():Void
    {
        this.promise.resolve(0);
        try {
            this.promise.done(function(arg:Int):Void {});
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }

    /**
     * Checks if exceptions thrown in Callbacks are catched.
     * If they are not, Callbacks that would need to be called are not executed
     * because one of the Callbacks before had thrown an exception.
     *
     * Reminder: resolved() Callbacks are executed before done()s
     *
     * Attn: This test depends on the resolve() and resolved() methods - make sure all tests for those
     * methods work before looking for errors in resolve() and resolved() when this test fails.
     */
    public function testExecuteCallbacksCatchesException():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            throw "Exception in Callback";
        });
        this.promise.done(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.resolve(input);
        assertTrue(executed);
    }

    /**
     * Checks if executeCallbacks() iterates over a copy of the registered Callbacks.
     *
     * It could be that Callbacks add other Callbacks to the Promise, which could bring
     * problem with it. Therefor the executeCallbacks() method should iterate over a copy
     * of all "til-then" added Callbacks.
     *
     * Attn: This test depends on the resolved() and done() methods - make sure all tests for those
     * methods work before looking for errors in executeCallbacks() when this test fails.
     */
    public function testExecuteCallbacksIteratesOverCopy():Void
    {
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            this.promise.done(function(arg:Int):Void {
                executed = true;
            });
        });
        assertFalse(executed);
    }

    /**
     * Checks if the isDone() method works correctly.
     */
    public function testIsReady():Void
    {
        assertFalse(this.promise.isDone());

        this.promise.resolve(0);
        assertTrue(this.promise.isDone());
    }

    /**
     * Checks if the isRejected() method works correctly.
     */
    public function testIsRejected():Void
    {
        assertFalse(this.promise.isRejected());

        this.promise.reject(0);
        assertTrue(this.promise.isRejected());
    }

    /**
     * Checks if the isRejected() method works correctly when the Promise has been resolved.
     */
    public function testIsRejectedWhenResolved():Void
    {
        this.promise.resolve(0);
        assertFalse(this.promise.isRejected());
    }

    /**
     * Checks if the isResolved() method works correctly.
     */
    public function testIsResolved():Void
    {
        assertFalse(this.promise.isResolved());

        this.promise.resolve(0);
        assertTrue(this.promise.isResolved());
    }

    /**
     * Checks if the isResolved() method works correctly when the Promise has been rejected.
     */
    public function testIsResolvedWhenRejected():Void
    {
        this.promise.reject(0);
        assertFalse(this.promise.isResolved());
    }

    /**
     * Checks that when multiple resolves are required, Callback functions
     * are not executed before all required resolves have been called.
     */
    public function testMultipleResolves():Void
    {
        var executed:Bool = false;
        this.promise = new hxdispatch.Promise<Int>(2);
        this.promise.done(function(arg:Int):Void {
            executed = true;
        });

        this.promise.resolve(0);
        assertFalse(executed);

        this.promise.resolve(0);
        assertTrue(executed);
    }

    /**
     * Checks if the reject() method throws an Exception when one tries to reject the
     * Promise twice.
     */
    public function testRejectThrowsWorkflowException():Void
    {
        this.promise.reject(0);
        try {
            this.promise.reject(0);
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }

    /**
     * Checks if the rejected() Callbacks are executed when the Promise gets rejected.
     *
     * Attn: This test depends on the reject() method - make sure all tests for that
     * method work before looking for errors in reject() when this test fails.
     */
    public function testRejected():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.rejected(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.reject(5);
        assertTrue(executed);
    }

    /**
     * Checks if the rejected() Callbacks are executed when the Promise gets resolved.
     *
     * Attn: This test depends on the resolve() method - make sure all tests for that
     * method work before looking for errors in resolve() when this test fails.
     */
    public function testRejectedWhenResolved():Void
    {
        var executed:Bool = false;
        this.promise.rejected(function(arg:Int):Void {
            executed = true;
        });
        this.promise.resolve(0);
        assertFalse(executed);
    }

    /**
     * Checks if the rejected() method throws an Exception when trying to add Callbacks
     * after the Promise has been marked as done.
     *
     * Attn: This test depends on the resolve() method - make sure all tests for that
     * method work before looking for errors in resolve() when this test fails.
     */
    public function testRejectedThrowsWorkflowException():Void
    {
        this.promise.resolve(0);
        try {
            this.promise.rejected(function(arg:Int):Void {});
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }

    /**
     * Checks if the resolve() method throws an Exception when one tries to resolve the
     * Promise twice.
     */
    public function testResolveThrowsWorkflowException():Void
    {
        this.promise.resolve(0);
        try {
            this.promise.resolve(0);
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }

    /**
     * Checks if the resolved() Callbacks are executed when the Promise gets resolved.
     *
     * Attn: This test depends on the resolve() method - make sure all tests for that
     * method work before looking for errors in resolve() when this test fails.
     */
    public function testResolved():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.resolve(input);
        assertTrue(executed);
    }

    /**
     * Checks if the resolved() Callbacks are executed when the Promise gets rejected.
     *
     * Attn: This test depends on the reject() method - make sure all tests for that
     * method work before looking for errors in reject() when this test fails.
     */
    public function testResolvedWhenRejected():Void
    {
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            executed = true;
        });
        this.promise.reject(0);
        assertFalse(executed);
    }

    /**
     * Checks if the resolved() method throws an Exception when trying to add Callbacks
     * after the Promise has been marked as done.
     *
     * Attn: This test depends on the resolve() method - make sure all tests for that
     * method work before looking for errors in resolve() when this test fails.
     */
    public function testResolvedThrowsWorkflowException():Void
    {
        this.promise.resolve(0);
        try {
            this.promise.resolved(function(arg:Int):Void {});
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }
}

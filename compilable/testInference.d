
/***************************************************/
// 6265.

pure nothrow @safe int h6265() {
    return 1;
}
int f6265a(alias g)() {
    return g();
}
pure nothrow @safe int i6265a() {
    return f6265a!h6265();
}

int f6265b()() {
    return h6265();
}
pure nothrow @safe int i6265b() {
    return f6265b();
}

pure nothrow @safe int i6265c() {
    return {
        return h6265();
    }();
}

/***************************************************/
// Make sure a function is not infered as pure if it isn't.

int fNPa() {
    return 1;
}
int gNPa()() {
    return fNPa();
}
static assert( __traits(compiles, function int ()         { return gNPa(); }));
static assert(!__traits(compiles, function int () pure    { return gNPa(); }));
static assert(!__traits(compiles, function int () nothrow { return gNPa(); }));
static assert(!__traits(compiles, function int () @safe   { return gNPa(); }));

/***************************************************/
// Need to ensure the comment in Expression::checkPurity is not violated.

void fECPa() {
    void g()() {
        void h() {
        }
        h();
    }
    static assert( is(typeof(&g!()) == void delegate() pure));
    static assert(!is(typeof(&g!()) == void delegate()));
}

void fECPb() {
    void g()() {
        void h() {
        }
        fECPb();
    }
    static assert(!is(typeof(&g!()) == void delegate() pure));
    static assert( is(typeof(&g!()) == void delegate()));
}

/***************************************************/
// 5936

auto bug5936c(R)(R i) @safe pure nothrow {
    return true;
}
static assert( bug5936c(0) );

/***************************************************/
// 6351

void bug6351(alias dg)()
{
    dg();
}

void test6351()
{
    void delegate(int[] a...) deleg6351 = (int[] a...){};
    alias bug6351!(deleg6351) baz6531;
}

/***************************************************/
// 7017

template map7017(fun...) if (fun.length >= 1)
{
    auto map7017()
    {
        struct Result {
            this(int dummy){}   // impure member function
        }
        return Result(0);   // impure call
    }
}

int foo7017(immutable int x) pure nothrow { return 1; }

void test7017a() pure
{
    int bar7017(immutable int x) pure nothrow { return 1; }

    static assert(!__traits(compiles, map7017!((){})()));   // should pass, but fails
    static assert(!__traits(compiles, map7017!q{ 1 }()));   // pass, OK
    static assert(!__traits(compiles, map7017!foo7017()));  // pass, OK
    static assert(!__traits(compiles, map7017!bar7017()));  // should pass, but fails
}

/***************************************************/
// 7017 (little simpler cases)

auto map7017a(alias fun)() { return fun();     }    // depends on purity of fun
auto map7017b(alias fun)() { return;           }    // always pure
auto map7017c(alias fun)() { return yyy7017(); }    // always impure

int xxx7017() pure { return 1; }
int yyy7017() { return 1; }

void test7017b() pure
{
    static assert( __traits(compiles, map7017a!xxx7017() ));
    static assert(!__traits(compiles, map7017a!yyy7017() ));

    static assert( __traits(compiles, map7017b!xxx7017() ));
    static assert( __traits(compiles, map7017b!yyy7017() ));

    static assert(!__traits(compiles, map7017c!xxx7017() ));
    static assert(!__traits(compiles, map7017c!yyy7017() ));
}

/***************************************************/
// Test case from std.process

auto escapeArgumentImpl(alias allocator)()
{
    return allocator();
}

auto escapeShellArgument(alias allocator)()
{
    return escapeArgumentImpl!allocator();
}

pure string escapeShellArguments()
{
    char[] allocator()
    {
        return new char[1];
    }

    /* Both escape!allocator and escapeImpl!allocator are impure,
     * but they are nested template function that instantiated here.
     * Then calling them from here doesn't break purity.
     */
    return escapeShellArgument!allocator();
}

/***************************************************/
// 8751

alias bool delegate(in int) pure Bar8751;
Bar8751 foo8751a(immutable int x) pure
{
    return y => x > y; // OK
}
Bar8751 foo8751b(const int x) pure
{
    return y => x > y; // error -> OK
}

/***************************************************/
// 8793

alias bool delegate(in int) pure Dg8793;
alias bool function(in int) pure Fp8793;

Dg8793 foo8793fp1(immutable Fp8793 f) pure { return x => (*f)(x); } // OK
Dg8793 foo8793fp2(    const Fp8793 f) pure { return x => (*f)(x); } // OK

Dg8793 foo8793dg1(immutable Dg8793 f) pure { return x => f(x); } // OK
Dg8793 foo8793dg2(    const Dg8793 f) pure { return x => f(x); } // error -> OK

Dg8793 foo8793pfp1(immutable Fp8793* f) pure { return x => (*f)(x); } // OK
Dg8793 foo8793pdg1(immutable Dg8793* f) pure { return x => (*f)(x); } // OK

// general case for the hasPointer type
Dg8793 foo8793ptr1(immutable int* p) pure { return x => *p == x; } // OK

/***************************************************/

// Add more tests regarding inferences later.


/* REQUIRED_ARGS: -unittest
*/
module e7804;

struct Bar {static struct B{}}
alias BarB = __traits(getMember, Bar, "B");
static assert(is(BarB == Bar.B));
static assert(is(const(__traits(getMember, Bar, "B")) == const(Bar.B)));

alias BarBParent = __traits(parent, BarB);
static assert(is(BarBParent == Bar));

struct Foo {alias MyInt = int;}
alias FooInt = __traits(getMember, Foo, "MyInt");
static immutable FooInt fi = 42;
static assert(fi == 42);
void declVsStatementSupport()
{
    __traits(getMember, Foo, "MyInt") i1 = 1;
    const(__traits(getMember, Foo, "MyInt")) i2 = 1;
    assert(i1 == i2);
}


enum __traits(getMember, Foo, "MyInt") a0 = 12;
static assert(is(typeof(a0) == int));
static assert(a0 == 12);


const __traits(getMember, Foo, "MyInt") a1 = 46;


__traits(getMember, Foo, "MyInt") a2 = 78;


const(__traits(getMember, Foo, "MyInt")) a3 = 63;


struct WithSym {static int foo; static int bar(){return 42;}}
alias m1 = __traits(getMember, WithSym, "foo");
alias m2 = WithSym.foo;
static assert(__traits(isSame, m1, m2));
alias f1 = __traits(getMember, WithSym, "bar");
alias f2 = WithSym.bar;
static assert(__traits(isSame, f1, f2));


auto ovld(const(char)[] s){return s;}
auto ovld(int i){return i;}
alias ovlds = __traits(getOverloads, e7804, "ovld");


struct TmpPrm(T)
if (is(T == int)){T t;}
TmpPrm!(__traits(getMember, Foo, "MyInt")) tpt = TmpPrm!(__traits(getMember, Foo, "MyInt"))(42);


@Foo @(1) class Class
{
    final void virtual(){}
    int virtual(int p){return p;}
    void test(this T)()
    {
        alias vf = __traits(getVirtualFunctions, Class, "virtual");
        assert(vf.length == 2);
        alias vm = __traits(getVirtualMethods, Class, "virtual");
        assert(vm.length == 1);
        assert(vm[0](42) == 42);
        alias attribs = __traits(getAttributes, Class);
        assert(attribs.length == 2);
        assert(attribs[0] is Foo);
        assert(attribs[1] == 1);

        alias objectAll = __traits(allMembers, Object);
        alias classDerived = __traits(derivedMembers, Class);
        alias classAll = __traits(allMembers, Class);
        enum Seq(T...) = T;
        static assert (classAll == Seq!(classDerived, objectAll));
    }
}


struct UnitTests
{
    static int count;
    unittest { count++; }
    unittest {++++count;}
    static void test()
    {
        alias tests = __traits(getUnitTests, UnitTests);
        static assert(tests.length == 2);
        foreach(t; tests) t();
        assert(count == 6); // not 3 because executed automatically (DRT) then manually
    }
}

void main()
{
    declVsStatementSupport();
    assert(a1 == 46);
    assert(a2 == 78);
    assert(a3 == 63);
    assert(f1() == f2());
    Foo.MyInt fmi = cast(__traits(getMember, Foo, "MyInt")) 0;
    auto c = __traits(getMember, Foo, "MyInt").max;
    assert(c == int.max);
    assert(ovlds[0]("farfelu") == "farfelu");
    assert(ovlds[1](42) == 42);
    (new Class).test();
    UnitTests.test();
}

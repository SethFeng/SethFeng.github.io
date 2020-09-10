Java AOP
===

## java的Proxy api invoke
在说到AOP的Java实现，可能会优先想到java的Proxy api，通过invoke方法拦截处理相应的代码逻辑,但是proxy 是面向接口的，被代理的class的所有方法调用都会通过反射调用invoke 方法，相对性能开销大。

## Instrument
另外的还有Java 5提供的Instrument，比较适用于监控检查方面，但在处理灵活的代码逻辑方面并不合适。

## ASM
ASM 框架对用户屏蔽了整个类字节码的长度，偏移量，能够更加灵活和方便得实现对字节码的解析和操作。其主要提供了两部分主要的API，Core Api 及Tree Api。
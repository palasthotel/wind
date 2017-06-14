# Wind - Dependency Injection for Swift

Wind is a light-weight dependency injection framework written in pure swift.

Wind uses empty protocols as tags to detect dependencies. It has built-in support for factories and singletons and provides an easy way to blend external framework singletons (like FileManager, UserDefaults) into the container.

Protocols are also used to give Wind insights about how to instantiate components.

## Protocols

The most important protocol is `Component` - the base for every thing that may need dependencies. If you want an easier way to handle Dependencies, use `AutomaticDependencyHandling`. That will add an implementation to your class and makes it a lot easier to get the dependencies when needed. More on that later.
If your class is a singleton, simply add `Singleton` to your class.  

Components are not the only protocol trait to handle: dependency resolution is another protocol-driven topic. You can choose between 3 different Resolution mechanisms: Simple, Direct and Indirect. All you have to do is add the corresponding protocol (`SimpleResolver`,`DirectResolver`,`IndirectResolver`) to your class.

## Dependency Resolution

Wind tries to be as type-safe as possible and therefore does not centralize dependency resolution. Every component is its own dependency resolver. There are three implementations already available for you to use. If you want to handle it yourself, simply implement `Resolver` on your own.

### Direct

Direct Resolution is the simplest possible mechanism: it only works when you directly ask the container to resolve the specific type. This resolver does not fullfill dependencies on other components. Its meant to be used for "launch classes" which are normally not visible to other components and only used to fetch a graph of objects out of the container. We encourage you to use it very rarely.

### Simple

Simple dependency resolution works as follows: if the dependent component conforms to the DependencyToken protocol, the resolving component hands in itself under its own type. Therefore you need to define an empty protocol as the dependency "tag".

As we already defined all important parts, here is a sample:

```swift
protocol MyComponentDependency { }

class MyComponent: Singleton,AutomaticDependencyHandling,SimpleResolver {
    typealias DependencyToken = MyComponentDependency

    var dependencies:[String:Any] = [:]

    required init() {

    }
}
```

It's that easy. Your first component.

### Indirect

Indirect dependency resolution only differs in one thing: instead of publishing the class itself as a type, the object is cast into a protocol before fullfilling the dependency. This allows you to easily decouple the consumer from the component when testing. We encourage you to always use indirect resolution.

The sample looks like this:

```swift
protocol MyComponentDependency { }
protocol MyComponent {
    func foo() -> Void;
}

class MyComponentImplementation: MyComponent,Singleton,AutomaticDependencyHandling,IndirectResolver {
    typealias DependencyToken = MyComponentDependency
    typealias PublicInterface = MyComponent

    var dependencies:[String:Any] = [:]

    required init() {

    }

    func foo() -> Void {

    }
}
```

As you see, there is no real overhead between simple and indirect resolution. Whenever possible, use indirect depency resolution.

## The other side

So, how do you get your dependencies: that's plain simple:

```swift

class Consumer: Component,AutomaticDependencyHandling,SimpleResolver,Singleton,MyComponentDependency {
    var dependencies: [String : Component] = [:];
    
    required init() {

    }
}
```

This is essentially all you need. If you now want to access your dependency, you simply do so by calling `component()`. For example:

```swift

class Consumer: Component,AutomaticDependencyHandling,SimpleResolver,Singleton,MyComponentDependency {
    var dependencies: [String : Component] = [:];
    
    required init() {

    }

    func doWork() {
        let cmp:MyComponent! = component();
        cmp.foo();
    }
}
```

As You might already notice: wind does not support constructor injection. So you can't access any of your dependencies within init(). To ease work with the dependencies, the following pattern is very helpful:

```swift

class Consumer: Component,AutomaticDependencyHandling,SimpleResolver,Singleton,MyComponentDependency {
    var dependencies: [String : Component] = [:];
    
    required init() {

    }

    lazy var cmp:MyComponent! = self.component();

    func doWork() {
        cmp.foo();
    }

}
```

If you want to adopt this pattern, extensions on your dependency protocols can help you reduce the boilerplate code:

```swift

extension MyComponentDependency where Self:AutomaticDependencyHandling {
    var cmp:MyComponent! { get { return self.component(); } }


class Consumer: Component,AutomaticDependencyHandling,SimpleResolver,Singleton,MyComponentDependency {
    var dependencies: [String : Component] = [:];
    
    required init() {

    }

    func doWork() {
        cmp.foo();
    }

}
```


## Container Construction

Setting up a new container is really simple:

```swift

var container = Container();
MyComponentImplementation.register(in:container);
try! container.bootstrap();

var instance:MyComponent! = container.resolve();

```

That's it. First we instantiate a new container. Next up we register our components by calling register() on the types. The static function is already provided by wind. 
Finally, we have to call bootstrap() to set all resolver dependencies up. Afterwards we can start to resolve components out of the container, which will pull out all dependencies on the fly.

## Advanced Topics

### Components with foreign lifecycles

When dealing with UIKit (especially UIViewController subclasses and UIViews), the system frameworks will create your instances when needed. Thus these Objects live outside of wind and neither get dependency resolution nor can be used to satisfy dependencies.

There is no perfect solution for this - as wind isn't able to trigger the lifecycle of these classes as soon as another component depends on it. However what wind is capable of: resolve these kind of dependencies as soon as the object gets created and registers itself with the container.

Your Component needs to adopt at least two protocols: `ForeignInstantiable` and one of the resolver protocols. As Wind now knows that this component will be provided at some point in the future, it can be registered with a container just as any other component. 
As soon as your component gets instantiated, it needs to call `resolveMe(in container:Container)` in order to start late dependency resolution.

Remember: your component has to follow a different lifecycle than the components managed by wind. That's the main reason why you're reading this paragraph. As such every consumer which depends on the foreign lifecycle component isn't allowed to keep a strong reference.

So your consumer needs to conform to `WeakDependencyAware` - this protocol handles weak references. If you don't want to implement the details on your own, simply add a new variable:

```swift
var weakDependencies:[String:WeakReference] = [:]
```

and conform to `AutomaticWeakDependencyHandling` - this protocol provides you with a default implementation and adds a new function `weakComponent()`. This function is known to return nil often - whenever the component is not there. Your application needs to know wether the component is available. Wind isn't going to tell you. 

### Storyboard Consumer Support

Wind comes with support for storyboards: you can set your application Container on UIApplication. The container set there will be used to fullfill Dependencies for every Storboard. Additionally you can override the Container by setting one on your UIStoryboard instance.
Besides that you need to add an Object of Wind's `StoryboardResolver` to your view controller and add your view controller as an outlet to it. As soon as your view controller gets instantiated the StoryboardResolver will start a dependency resolution for it using the container provided by UIStoryboard or UIApplication.


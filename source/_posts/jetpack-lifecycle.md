title: Jetpack Lifecycle
date: 2020-09-10 19:47:47
tags: [Android, Jetpack, Lifecycle]
categories: [Android]
---
Support Library 26.1.0之后的`Fragments`和`Activity`都已经继承了`LifecycleOwner`接口
<!-- more -->
`ActivityThread#handleBindApplication`里初始化`Provider`。`ProcessLifecycleOwnerInitializer`作为一个注册的C`ontentProvider`，在`Application`初始化时就初始化了。
```java
public class ProcessLifecycleOwnerInitializer extends ContentProvider {
    @Override
    public boolean onCreate() {
        LifecycleDispatcher.init(getContext());
        ProcessLifecycleOwner.init(getContext());
        return true;
    }
    ...
}
```
`LifecycleDispatcher`注册了`Application.ActivityLifecycleCallbacks`监听，当`Activity`被创建时给`Activity`挂载一个`ReportFragment`。这里并没有过分侵入`Activity`的代码来感知生命周期变化，而是通过`ReportFragment`的生命周期来感知的。
```java
class LifecycleDispatcher {
	...
	static void init(Context context) {
        if (sInitialized.getAndSet(true)) {
            return;
        }
        ((Application) context.getApplicationContext())
                .registerActivityLifecycleCallbacks(new DispatcherActivityCallback());
    }
    ...
    static class DispatcherActivityCallback extends EmptyActivityLifecycleCallbacks {
    	@Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            if (activity instanceof FragmentActivity) {
                ((FragmentActivity) activity).getSupportFragmentManager()
                        .registerFragmentLifecycleCallbacks(mFragmentCallback, true);
            }
            ReportFragment.injectIfNeededIn(activity);
        }
    }
    ...
}
```
一个`Activity`挂载了一个`ReportFragment`来感知生命周期变化。发生变化时，`ReportFragment`分发事件给`Activity`的`LifecycleRegistry`，`LifecycleRegistry`再分发给App添加到`Activity` lifecycle的监听器。
```java
public class ReportFragment extends Fragment {
	...
	public static void injectIfNeededIn(Activity activity) {
        // ProcessLifecycleOwner should always correctly work and some activities may not extend
        // FragmentActivity from support lib, so we use framework fragments for activities
        android.app.FragmentManager manager = activity.getFragmentManager();
        if (manager.findFragmentByTag(REPORT_FRAGMENT_TAG) == null) {
            manager.beginTransaction().add(new ReportFragment(), REPORT_FRAGMENT_TAG).commit();
            // Hopefully, we are the first to make a transaction.
            manager.executePendingTransactions();
        }
    }
    ...
    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        ...
        dispatch(Lifecycle.Event.ON_CREATE);
    }

    @Override
    public void onStart() {
        ...
        dispatch(Lifecycle.Event.ON_START);
    }

    @Override
    public void onResume() {
        ...
        dispatch(Lifecycle.Event.ON_RESUME);
    }
    ...
    private void dispatch(Lifecycle.Event event) {
        Activity activity = getActivity();
        ...
        if (activity instanceof LifecycleOwner) {
            Lifecycle lifecycle = ((LifecycleOwner) activity).getLifecycle();
            if (lifecycle instanceof LifecycleRegistry) {
                ((LifecycleRegistry) lifecycle).handleLifecycleEvent(event);
            }
        }
    }
    ...
}
```
`SupportActivity`是`Lifecycle`的拥有者，它有Lifecycle的注册器，App通过向其添加监听器来实现该`Activity`生命周期的监听。
```java
package android.support.v4.app;
...
public class SupportActivity extends Activity implements LifecycleOwner, Component {
    private LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);

    protected void onSaveInstanceState(Bundle outState) {
        this.mLifecycleRegistry.markState(State.CREATED);
        super.onSaveInstanceState(outState);
    }

    public Lifecycle getLifecycle() {
        return this.mLifecycleRegistry;
    }
    ...
}
```
`Fragment`像`SupportActivity`一样是`Lifecycle`的拥有者，用法同`Activity`。
```java
package android.support.v4.app;
...
public class Fragment implements ComponentCallbacks, OnCreateContextMenuListener, LifecycleOwner, ViewModelStoreOwner {
    ...
    LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);
    
    @Override
    public Lifecycle getLifecycle() {
        return mLifecycleRegistry;
    }

    void performCreate(Bundle savedInstanceState) {
        ...
        mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
    }
    ...
    void performStart() {
        ...
        mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START);
    }
    ...
}
```
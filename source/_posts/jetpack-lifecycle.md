title: Jetpack Lifecycle
date: 2020-09-10 19:47:47
tags: [Android, Jetpack, Lifecycle]
categories: [Android, JetPack]
---
## Why Lifecycle
`Activity`和`Fragment`在设计之初就承载了太多，即充当View的角色，又接受Framework的生命周期管理。开发者需在对应的生命周期回调里处理相应逻辑，导致开发者的`Activity`和`Fragment`代码往往又臭又长，职责不清。这时候期望能有个监听注册器，接收监听器的注册并把生命周期变化事件分发给它们。官方在Support Library 26.1.0给出了具体实现。

## Lifecycle原理
Support Library 26.1.0之后的`Fragments`和`Activity`都已经继承了`LifecycleOwner`接口
<!-- more -->
`ActivityThread#handleBindApplication`里初始化`Provider`。`ProcessLifecycleOwnerInitializer`作为一个注册的`ContentProvider`，在`Application`初始化时就初始化了。
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
`LifecycleRegistry`持有`Activity`和`Fragment`的弱引用，通过`addObserver`和`removeObserver`开始和移除生命周期监听。
```java
public class LifecycleRegistry extends Lifecycle {
    private final WeakReference<LifecycleOwner> mLifecycleOwner;

    public void addObserver(@NonNull LifecycleObserver observer) {
        ...
    }

    public void removeObserver(@NonNull LifecycleObserver observer) {
        ...
    }
}
```
需要注意的是，在不同的地方添加生命周期监听，监听到的事件可能并不完整。
- 在`onCreate`/`onStart`/`onResume`添加的监听时会收到完整的`onCreate`->`onStart`->`onResume`回调。
- 在`onPause`里添加监听当次收不到回调，之后首次触发生命周期变化时会收到`onCreate`->`onStart`回调。
- `onStop`里添加监听当次收到`onCreate`回调，当次不会收到`onStop`回调。
- `onDestroy`里添加监听收不到回调。

## LiveData、ViewModel
`LiveData`和`ViewModel`是基于Lifecycle生命周期的灵活应用，基于生命周期的数据更新和UI刷新，形成了新的MVVM架构。
```kotlin
data class Account(var name: String) {
}

class AccountLiveData : MutableLiveData<Account>() {
}

class AccountViewModel : ViewModel() {
    val liveData = AccountLiveData()
}
```
`ViewModelProviders`根据传入的ViewModel类型，创建一个全局唯一ViewModel对象。下次再创建时ViewModel，返回的是缓存的ViewModel对象，全局只有唯一一个Model对象。这在App的登录模块里是不是很适用呢？
```kotlin
val viewModel = ViewModelProviders.of(this).get(AccountViewModel::class.java)
// 监听数据变化
viewModel.liveData.observe(this, {
    textView.text = it?.name // 更新UI
})
// 更新数据
viewModel.liveData.setValue(Account("Tom")) // 主线程调用
viewModel.liveData.postValue(Account("Tom")) // 异步线程调用
```
基于Lifecycle的MVVM架构确保了`Activity`/`Fragment`在前台时才会通知监听器数据变化了，`View`再响应相应的变化，避免了在后台刷新UI。而在开发时，在后台时数据变化，很容易就直接刷UI了，或者为了避免后台刷UI需要采取复杂的后台数据缓存-切前台刷新策略。

## Room
Room基于LiveData，把存储在Sqlite的数据映射成对象，并可实现数据库数据与生命周期的直接绑定。Room生成可直接返回LiveData，方便开发者监听和修改数据。
```kotlin
@Entity(tableName = "Account")
data class Account(
    @PrimaryKey
    val id: Int,
    var name: String
)
```

```kotlin
@Dao
interface AccountDao {

    @Query("SELECT * FROM Account")
    fun getAccountLive(): LiveData<List<Account>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun addAccount(account: Account)

    @Query("DELETE FROM Account")
    fun delete()

    @Update
    fun update(account: Account)
}
```

Lifecycle、LiveData、ViewModel和Room作为Android App的架构组件，使用它们可以快速构建出优良App。
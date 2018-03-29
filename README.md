# AninationTest
CAAnimationTestDemo

#### LYQCAAnimationDelegate
这个delegate是基于CAAnimationDelegate的封装，将原本需要写在系统delegate方法中的处理，放在了closure中，让每一个CAAnimation对象拥有一个独立的delegate，并直接在closure中传入后续执行的操作，省去了在系统delegate方法中对anim对象进行判断的麻烦。

当然，我们也可以通过对animation对象调用`setValue(value forKey: xxxkey)`的方式进行，给每个animation设置identifier，这样我们同样可以在系统的delegate方法中，通过`valueForKey`方法获取identifier，得到对应的animation进行操作。

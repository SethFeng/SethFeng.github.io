@regex

w: word
W: not word
(\w+): match a word and grouped, fetched by \1

d: digital
D: not digital
\w+: n digital


L: lower case
U: upper case
(\w) -> \L\1

^: line start
$: line end

{n}: repeat n times

=.*$: delete all until line end when start with `=`



convert json string to objc Object property:

"(\w+)": \d+,{0,1} -> @property(nonatomic, assign) NSInteger \1;

"(\w+)": true|false,{0,1} -> @property(nonatomic, assign) BOOL \1;

"(\w+)": ".*"|null,{0,1} -> @property(nonatomic) NSString *\1;

"(\w+)": \[.*\],{0,1} -> @property(nonatomic) NSArray<NSString *> *\1;

"(\w+)": { -> @interface \1 : NSObject
}, -> @end

"(\w+)": { ->
@property(nonatomic) \1 *\1;
@interface \1 : NSObject

} -> @end



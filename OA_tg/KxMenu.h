

#import <Foundation/Foundation.h>

//static NSString *departmentAll=@"全部部门";
//static NSString *departmentYF=@"研发部";
//static NSString *departmentSC=@"市场部";
//static NSString *departmentXX=@"信息部";
//static NSString *departmentXZ=@"行政部";
//static NSString *departmentCW=@"财务部";

#define departmentAll @"全部部门"
#define departmentYF @"研发部"
#define departmentSC @"市场部"
#define departmentXX @"信息部"
#define departmentXZ @"行政部"
#define departmentCW @"财务部"

@interface KxMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, assign) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action;

@end

@interface KxMenu : NSObject

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems;

+ (void) dismissMenu;

+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end

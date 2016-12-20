//
//  SourceEditorCommand.m
//  AutomaticCompletion
//
//  Created by chairman on 16/12/5.
//  Copyright © 2016年 LaiYoung_. All rights reserved.
//

#import "SourceEditorCommand.h"
#import <Cocoa/Cocoa.h>

@implementation SourceEditorCommand
static inline BOOL VerifyInstanceMethod(NSString *string) {
    if ([string containsString:@"-"]) {
        return YES;
    }
    return NO;
}

static inline NSString *FetchCls(NSString *string) {
    if ([string containsString:@"("]) {
        NSRange leftRange = [string rangeOfString:@"("];
        NSRange rightRange = [string rangeOfString:@")"];
        NSUInteger len = rightRange.location - leftRange.location - 1;//-1 是去掉右半边括号
        NSString *clsString = [string substringWithRange:NSMakeRange(leftRange.location+1, len)];//获取括号内的文本
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:clsString];
        [mutableString deleteCharactersInRange:[clsString rangeOfString:@"*"]];//删除＊
        clsString = [mutableString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return clsString;
    }
    return nil;
}

static inline NSString *FetchProperty(NSString *string) {
    NSUInteger loc = [string rangeOfString:@")"].location;
    NSString *rightString = [string substringWithRange:NSMakeRange(loc+1, string.length - (loc + 1))];
    NSMutableString *mutableString = [[NSMutableString alloc] initWithString:rightString];
    if ([rightString containsString:@"{"]) {
        [mutableString deleteCharactersInRange:[rightString rangeOfString:@"{"]];//如果包含{，就删除
    }
    rightString = [mutableString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return rightString;
}

static inline BOOL ExistsWithPropertyAndLines(NSString *propertyName,NSArray *lines) {
    NSString *judgeString = [NSString stringWithFormat:@"if (!_%@)",propertyName];
    for (NSString *lineText in lines) {
        if ([lineText containsString:judgeString]) {
            return YES;
        }
    }
    return NO;
}

static inline NSArray *AutomatedCompletionWithClsAndProperty(NSString *clsName, NSString *propertyName) {
    NSMutableArray *array = @[].mutableCopy;
    NSString *methodString = [NSString stringWithFormat:@"- (%@ *)%@",clsName,propertyName];
    NSString *beginString = @"{";
    NSString *judgeString = [NSString stringWithFormat:@"   if (!_%@) {",propertyName];
    NSString *initString = [NSString stringWithFormat:@"        _%@ = [[%@ alloc] init];",propertyName,clsName];
    NSString *returnString = [NSString stringWithFormat:@"   return _%@;",propertyName];
    NSString *judgeEndString = @"    }";
    NSString *endString = @"}";
    
    [array addObject:methodString];
    [array addObject:beginString];
    [array addObject:judgeString];
    [array addObject:initString];
    
    if ([clsName isEqualToString:@"UIImageView"]) {
        NSString *contentModeString = [NSString stringWithFormat:@"        _%@.contentMode = UIViewContentModeScaleAspectFit;",propertyName];
        NSString *imageString = [NSString stringWithFormat:@"        _%@.image = [UIImage imageNamed:<#(nonnull NSString *)#>];",propertyName];
        [array addObject:contentModeString];
        [array addObject:imageString];
    } else if ([clsName isEqualToString:@"UIButton"]) {
        NSString *setFontString = [NSString stringWithFormat:@"        _%@.titleLabel.font = <#Font#>;",propertyName];
        NSString *setTitleStirng = [NSString stringWithFormat:@"       [_%@ setTitle:QTLocal(<#XXX#>) forState:UIControlStateNormal];",propertyName];
        NSString *setTitleColorString = [NSString stringWithFormat:@"       [_%@ setTitleColor:<#Color#> forState:UIControlStateNormal];",propertyName];
        NSString *setTargetString = [NSString stringWithFormat:@"       [_%@ addTarget:self action:@selector(<#selector#>) forControlEvents:UIControlEventTouchUpInside];",propertyName];
        [array addObject:BackgroundColorStringWithProperty(propertyName)];
        [array addObject:setFontString];
        [array addObject:setTitleStirng];
        [array addObject:setTitleColorString];
        [array addObject:setTargetString];
    } else if ([clsName isEqualToString:@"UITableView"]) {
        initString = [NSString stringWithFormat:@"        _%@ = [[UITableView alloc] initWithFrame:<#(CGRect)#> style:<#(UITableViewStyle)#>]",propertyName];
        NSString *footerViewString = [NSString stringWithFormat:@"        _%@.tableFooterView = [[UIView alloc] init];",propertyName];
        NSString *registerString = [NSString stringWithFormat:@"        [_%@ registerClass:<#(nullable Class)#> forCellReuseIdentifier:NSStringFromClass(self.class)];",propertyName];
        NSString *annotationString =@"        /** iPad 适配 */";
        NSString *adaperiPadLine1String = [NSString stringWithFormat:@"        if ([_%@ respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {",propertyName];
        NSString *adaperiPadLine2String = [NSString stringWithFormat:@"            _%@.cellLayoutMarginsFollowReadableWidth = NO;",propertyName];
        NSString *adaperiPadLine3String = [NSString stringWithFormat:@"        }"];
        [array removeLastObject];
        [array addObject:initString];
        [array addObject:BackgroundColorStringWithProperty(propertyName)];
        [array addObject:DatasourceStringWithProperty(propertyName)];
        [array addObject:DelegateStringWithProperty(propertyName)];
        [array addObject:footerViewString];
        [array addObject:registerString];
        [array addObject:annotationString];
        [array addObject:adaperiPadLine1String];
        [array addObject:adaperiPadLine2String];
        [array addObject:adaperiPadLine3String];
    } else if ([clsName isEqualToString:@"UIView"]) {
        [array addObject:BackgroundColorStringWithProperty(propertyName)];
    } else if ([clsName isEqualToString:@"UILabel"]) {
        NSString *textColor = [NSString stringWithFormat:@"        _%@.textColor = <#Color#>;",propertyName];
        [array addObject:FontStringWithProperty(propertyName)];
        [array addObject:textColor];
        [array addObject:BackgroundColorStringWithProperty(propertyName)];
    } else if ([clsName isEqualToString:@"UITextField"]) {
        NSString *returnKeyTypeString = [NSString stringWithFormat:@"        _%@.returnKeyType = <#UIReturnKeyType#>;",propertyName];
        NSString *keyboardAppearanceString = [NSString stringWithFormat:@"        _%@.keyboardAppearance = UIKeyboardAppearanceDefault;",propertyName];
        NSString *borderStyleString = [NSString stringWithFormat:@"        _%@.borderStyle = <#UITextBorderStyle#>;",propertyName];
        NSString *secureTextEntryString = [NSString stringWithFormat:@"        _%@.secureTextEntry = <#BOOL#>;",propertyName];
        NSString *clearButtonModeString = [NSString stringWithFormat:@"        _%@.clearButtonMode = UITextFieldViewModeWhileEditing;",propertyName];
        [array addObject:DelegateStringWithProperty(propertyName)];
        [array addObject:FontStringWithProperty(propertyName)];
        [array addObject:returnKeyTypeString];
        [array addObject:keyboardAppearanceString];
        [array addObject:borderStyleString];
        [array addObject:secureTextEntryString];
        [array addObject:clearButtonModeString];
    } else if ([clsName isEqualToString:@"UICollectionView"]) {
        NSString *flowLayoutInitString = [NSString stringWithFormat:@"        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];"];
        NSString *itemSizeString = [NSString stringWithFormat:@"        flowLayout.itemSize = <#CGSizeMake#>;"];
        NSString *minimumLineSpacingString = [NSString stringWithFormat:@"        flowLayout.minimumLineSpacing = <#xxx#>;"];
        NSString *minimumInteritemSpacingString = [NSString stringWithFormat:@"        flowLayout.minimumInteritemSpacing = <#xxx#>;"];
        initString = [NSString stringWithFormat:@"        _%@ = [[UICollectionView alloc] initWithFrame:<#CGRect#> collectionViewLayout:flowLayout];",propertyName];
        NSString *registerString = [NSString stringWithFormat:@"        [_%@ registerClass:<#(nullable Class)#> forCellWithReuseIdentifier:NSStringFromClass(self.class)];",propertyName];
        [array removeLastObject];
        [array addObject:flowLayoutInitString];
        [array addObject:itemSizeString];
        [array addObject:minimumLineSpacingString];
        [array addObject:minimumInteritemSpacingString];
        [array addObject:initString];
        [array addObject:BackgroundColorStringWithProperty(propertyName)];
        [array addObject:DelegateStringWithProperty(propertyName)];
        [array addObject:DatasourceStringWithProperty(propertyName)];
        [array addObject:registerString];
    }
    [array addObject:judgeEndString];
    [array addObject:returnString];
    [array addObject:endString];
    return array.copy;
}

static inline NSString *BackgroundColorStringWithProperty(NSString *propertyName) {
    return [NSString stringWithFormat:@"        _%@.backgroundColor = <#Color#>;",propertyName];
}

static inline NSString *DelegateStringWithProperty(NSString *propertyName) {
    return [NSString stringWithFormat:@"        _%@.delegate = (id)self;",propertyName];
}

static inline NSString *DatasourceStringWithProperty(NSString *propertyName) {
    return [NSString stringWithFormat:@"        _%@.dataSource = (id)self;",propertyName];
}

static inline NSString *FontStringWithProperty(NSString *propertyName) {
    return [NSString stringWithFormat:@"        _%@.font = <#Font#>;",propertyName];
}

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    NSInteger lineIndex = selection.start.line;//行
    NSString *lineText = invocation.buffer.lines[lineIndex];//行的文本
    NSArray *lines = invocation.buffer.lines;
    if (VerifyInstanceMethod(lineText)) {
        NSString *className = FetchCls(lineText);
        NSString *property = FetchProperty(lineText);
        if (!ExistsWithPropertyAndLines(property, lines)) {//这个getter不存在才执行
            [invocation.buffer.lines removeObjectAtIndex:lineIndex];//删除光标所在行，后面有自定义
            NSArray *array = AutomatedCompletionWithClsAndProperty(className, property);
            for (NSInteger index = 0; index <= array.count - 1; index++ ) {
                NSString *string = array[index];
                [invocation.buffer.lines insertObject:string atIndex:lineIndex + index];
            }
        }
    }
    completionHandler(nil);
}

@end

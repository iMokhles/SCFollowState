#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

%config(generator=internal)

@interface Friend : NSObject
- (id)initWithFriend:(id)arg1;
@property(nonatomic) long long type; // @synthesize type=_type;
@end

@interface SCProfilePictureThumbnail : UIView
@property(retain, nonatomic) UIImageView *ghostFaceView; // @synthesize ghostFaceView=_ghostFaceView;
@property(retain, nonatomic) UIImageView *ghostBorderView; // @synthesize ghostBorderView=_ghostBorderView;
@property(retain, nonatomic) UIImageView *profileImageView; // @synthesize profileImageView=_profileImageView;
@end

@interface SCFriendProfileCellView : UIView {
	UIView *_thumbnailContainer;
	SCProfilePictureThumbnail *_thumbnail;
}
@end

@interface SCFriendProfileCell : UITableViewCell {
    UIView *_bottomBorder;
    SCFriendProfileCellView *_friendProfileCellView;
}
@property(retain, nonatomic) SCFriendProfileCellView *friendProfileCellView; // @synthesize friendProfileCellView=_friendProfileCellView;
- (void)setBottomBorderRightOffset:(double)arg1;
- (void)setBottomBorderHidden:(_Bool)arg1;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;
@end

%hook SCMyContactsViewController
- (SCFriendProfileCell *)_getFriendProfileCellForFriend:(Friend *)arg1 onTableView:(UITableView *)arg2 atIndexPath:(NSIndexPath *)arg3 {
	SCFriendProfileCell *cell = %orig();
	if (cell) {
		if (arg1.type != 0x0) {
			cell.friendProfileCellView.layer.borderColor = [UIColor redColor].CGColor;
			cell.friendProfileCellView.layer.borderWidth = 1.0f;
		} else {
			cell.friendProfileCellView.layer.borderColor = [UIColor greenColor].CGColor;
			cell.friendProfileCellView.layer.borderWidth = 1.0f;
		}
	}
	return cell;
}
%end

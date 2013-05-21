#import <Foundation/Foundation.h>


@protocol StashCollectionViewDelegate <NSCollectionViewDelegate>
@optional

- (void)collectionView:(id)collectionView didTapItem:(NSCollectionViewItem *)collectionViewItem;


@end

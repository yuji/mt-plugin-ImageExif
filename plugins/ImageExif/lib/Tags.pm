package ImageExif::Tags

use strict;
use MT::Asset::Image::ImageEx;

sub _hdlr_asset_exif_property {
    my $ctx = shift;

    my $asset = $ctx->stash('asset')
        or return $ctx->error(MT->translate(
        "You used an MTAssetExifProperty tag outside of the context of an asset; " .
        "perhaps you mistakenly placed it outside of an 'MTAssets' container?"));

    my $class = ref($asset);
    return if $class ne 'MT::Asset::Image::ImageEx';

    $asset->get_exifinfo(@_);
}

sub _hdlr_asset_has_exif {
    my ($ctx, $args, $cond) = @_;
    my $asset = $ctx->stash('asset')
        or return $ctx->error(MT->translate(
        "You used an MTAssetHasExif tag outside of the context of an asset; " .
        "perhaps you mistakenly placed it outside of an 'MTAssets' container?"));

    my $class = ref($asset);
    return 0 if $class ne 'MT::Asset::Image::ImageEx';

    return $asset->has_exifinfo();
}

1;

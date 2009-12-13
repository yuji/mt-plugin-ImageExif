# Licence: GPL v2
#
# ToDo: Implement dynamic side
# $Id$
package MT::Plugin::ImageExif;

use strict;
use warnings;

use MT;
use MT::Asset::Image::ImageEx;

use base 'MT::Plugin';
our $VERSION = '1.0';

my $plugin = __PACKAGE__->new(
    {
        id          => 'ImageExif',
        name        => 'Supplemental image asset',
        description => 'Display image EXIF data, Edit asset template, and more.',
        author_name => 'Six Apart, Ltd.',
        author_link => 'http://www.sixapart.com/',
        version     => $VERSION,
    }
);
MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        tags => {
            block => {
                'AssetHasExif?' => \&_hdlr_asset_has_exif,
            },
            function => {
                'AssetExifProperty' => \&_hdlr_asset_exif_property,
            },
        },
        object_types   => {
            'asset.exif_image' => 'MT::Asset::Image::ImageEx',
        },
    });
}

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

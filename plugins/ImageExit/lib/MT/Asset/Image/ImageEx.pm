package MT::Asset::Image::ImageEx;

use strict;
use base qw( MT::Asset::Image );

use MT 4.0;
use Image::ExifTool qw(:Public);

__PACKAGE__->install_properties( { class_type => 'image', } );

sub extensions { [ qr/gif/i, qr/jpe?g/i, qr/png/i, ] }

sub class_label {
    MT->translate('Image');
}

sub class_label_plural {
    MT->translate('Images');
}

sub has_exifinfo {
    my $asset      = shift;
    my $cache_prop = $asset->_read_info();
    return defined $cache_prop->{'ExifVersion'} ? 1 : 0;
}

sub get_exifinfo {
    my $asset = shift;
    my ($param) = @_;

    return '' unless $param->{tag};
    my $cache_prop = $asset->_read_info();
    $cache_prop->{ $param->{tag} } || '';
}

sub as_html {
    my $asset   = shift;
    my ($param) = @_;
    my $blog    = $asset->blog;

    # Load embed template
    require MT::Template;
    my $tmpl = MT::Template->load(
        {
            blog_id => $blog->id,
            name    => 'Embedded html for asset',
            type    => 'custom'
        }
    );
    $tmpl = _make_template( $blog->id ) unless $tmpl;

    my %param = {};
    $param{url}  = MT::Util::encode_html( $asset->url );
    $param{name} = MT::Util::encode_html( $asset->label );
    if ( $param->{include} ) {
        require MT::Util;
        $param{include} = 1;

        if ( $param->{thumb} ) {
            my $thumb = MT::Asset->load( $param->{thumb_asset_id} )
              || return $asset->error(
                MT->translate(
                    "Can't load image #[_1]",
                    $param->{thumb_asset_id}
                )
              );
            $param{thumb}        = 1;
            $param{thumb_width}  = $thumb->image_width;
            $param{thumb_height} = $thumb->image_height;
            $param{thumb_url}    = MT::Util::encode_html( $thumb->url );
        }

        if ( $param->{popup} ) {
            my $popup = MT::Asset->load( $param->{popup_asset_id} )
              || return $asset->error(
                MT->translate(
                    "Can't load image #[_1]",
                    $param->{popup_asset_id}
                )
              );
            $param{popup}     = 1;
            $param{popup_url} = MT::Util::encode_html( $popup->url );
        }

        if ( $param->{wrap_text} && $param->{align} ) {
            $param{align} = $param->{align};
        }
    }

    my $ctx = $tmpl->context;
    $ctx->stash( 'asset', $asset );
    my $app = MT->instance;
    my $text = $app->build_page( $tmpl, \%param )
      or die $app->errstr;
    return $asset->enclose($text);
}

sub _make_template {
    my $blog_id = shift;

    require MT::Template;
    my $tmpl = plugin()->load_tmpl('embed.tmpl')
      or return undef;
    $tmpl->name('Embedded html for asset');
    $tmpl->blog_id($blog_id);
    $tmpl->type('custom');
    $tmpl->save;

    return $tmpl;
}

sub _read_info {
    my $asset = shift;

    my $cache_prop = $asset->{__exifinfo} || undef;
    unless ($cache_prop) {
        my $tool = new Image::ExifTool;
        ($cache_prop) = $tool->ImageInfo( $asset->file_path );
        return '' unless $cache_prop;
        $asset->{__exifInfo} = $cache_prop;
    }

    return $cache_prop;
}

sub plugin {
    return MT->component('ImageExif');
}

1;

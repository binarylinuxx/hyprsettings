pkgname=hyprsettings
pkgver=0.2.0
pkgrel=1
pkgdesc="a simple Control Panel for Hyprland"
arch=('any')
url="https://github.com/binarylinuxx/hyprsettings"
license=('GPL')
depends=('python' 'python-setuptools')
makedepends=('python-build' 'python-installer' 'python-wheel')
source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz"
        "hyprsettings.desktop")
sha256sums=('SKIP'
            'SKIP')

build() {
    cd "$pkgname-$pkgver"
    python -m build --wheel --no-isolation
}

package() {
    cd "$pkgname-$pkgver"
    
    python -m installer --destdir="$pkgdir" dist/*.whl
    
    install -Dm644 "$srcdir/hyprsettings.desktop" "$pkgdir/usr/share/applications/hyprsettings.desktop"
}

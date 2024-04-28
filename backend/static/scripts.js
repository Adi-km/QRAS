document.addEventListener('DOMContentLoaded', function () {
    var images = [
        '{{ url_for("static", filename="qrcodes/" + sid + ".png") }}',
        '{{ url_for("static", filename="qrcodes/" + date + pin + ".png") }}',
        '{{ url_for("static", filename="qrcodes/" + pin + ".png") }}'
    ];
    var currentIndex = 0;

    function changeImage() {
        document.getElementById('qr-code').src = images[currentIndex];
        currentIndex = (currentIndex + 1) % images.length;
    }

    setInterval(changeImage, 3000);
});

window.addEventListener('beforeunload', function (event) {
    closeAndDeleteQRCodes();
});

window.addEventListener('unload', function (event) {
    closeAndDeleteQRCodes();
});

function closeAndDeleteQRCodes() {
    // AJAX request to delete QR codes
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '{{ url_for("delete_qr_codes") }}', true);
    xhr.send();

    // Redirect to the login page
    window.location.href = '{{ url_for("index") }}';
}

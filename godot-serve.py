from http.server import HTTPServer, SimpleHTTPRequestHandler

class GodotHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        # redirects any load of "/" to go to the godot editor
        if self.path == "/":
            self.path = "/godot.editor.html"
        return super().do_GET()
    
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

HTTPServer(("0.0.0.0", 8060), GodotHandler).serve_forever()
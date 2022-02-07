### A backend framework for Dart.

```dart
   @RestController()
   class IndexController {
      @GetRoute()
      String get() {
         print('get route');
         return '';
      }

      @PostRoute()
      String create() {
         print('post route');
         return '';
      }
   }
```

#### TODO 
- Routing
   - Sub-Paths: users/1 
   - HTTP Methods
   - Query Parameters  
- Middleware
- Session
   - Cookie Management  
- SQL Querying 
- Terminal GUI for setting up and running the project. 
- Logging
- Document Generating
   - Swagger Page Generating
   - Client Code Generating
- README
- Tutorials


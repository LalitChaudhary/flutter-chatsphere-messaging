## Demo login

These accounts exist only inside the demo. They are not a GitHub login and they do not access a real service.

| Email | Password |
| --- | --- |
| lea@chatsphere.dev | `demo1234` |

﻿ChatSphere is a local thread. Sign in with lea@chatsphere.dev / demo1234. Messages start pending and can be marked sent. There is no end-to-end encryption.

Architecture: Riverpod. Duplicate ids keep the stronger receipt.

```bash
flutter pub get
flutter test
flutter run
```

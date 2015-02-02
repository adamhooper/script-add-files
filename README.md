Adds new documents to an existing document set

This is a **work in progress**. We're using it to solve https://www.pivotaltracker.com/story/show/87428800; eventually we'll probably just delete it because you'll be able to add documents via a UI instead of via the API.

Usage:

1. `npm install`
2. `DEBUG='*' ./index.js --server='https://www.overviewproject.org' --api-token=abcd file1.txt file2.txt file3.txt
3. `curl -XPOST 'https://www.overviewproject.org/api/v1/files/finish' -u 'abcd:x-auth-token'`

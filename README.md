Creates document sets and/or adds to an existing document set.

This project describes how to use Overview's
[Files API](http://docs.overviewproject.apiary.io/#reference/files) to add
files to a document set.

This project is for developers. If you're an end-user, just browse to
https://www.overviewproject.org and add files through the user interface.

# 1. Finding a document set and API token

To add files, we'll need `$DOCUMENT_SET_ID` and `$API_TOKEN`. We can get them
programmatically or through the UI.

## 1a) creating the document set via a creator API token

1. Browse to https://www.overviewproject.org/api-tokens and click "Generate token".
2. Copy the token you just generated. We'll refer to this token as `$CREATOR_API_TOKEN` and use it to create document sets.
3. `curl -XPOST 'https://www.overviewproject.org/api/v1/document-sets' -u '$CREATOR_API_TOKEN:x-auth-token' -d 'title=some-title'`
4. Scan the JSON result for `documentSet.id`. We'll refer to this as `$DOCUMENT_SET_ID`.
5. Scan the JSON result for `apiToken.token`. We'll refer to this token as `$API_TOKEN` and use it to add documents to document set `$DOCUMENT_SET_ID`.

## 1b) adding to an existing document set

1. Browse to your document set. The URL will look like `https://www.overviewproject.org/documentsets/123456`
2. We'll refer to the `123456` part of the URl above as `$DOCUMENT_SET_ID`.
3. Browse to `https://www.overviewproject.org/documentsets/$DOCUMENT_SET_ID/api-tokens` and click "Generate token".
4. Copy the token you just generated. We'll refer to this token as `$API_TOKEN` and use it to add documents to document set `$DOCUMENT_SET_ID`.

# 2. Adding files

## How it works

We'll do the following:

1. For each file, upload it to a pool of files unique to `$API_TOKEN`.
2. Send a "finish" request.

The uploading step is a bit tricky, hence this project. Overview supports thousands of small files, meaning it needs to give files unique IDs. It also supports huge files, meaning it needs _resume_. Before you know it, you need [a library just for uploading](https://github.com/overview/js-mass-upload).

## On the console

```sh
npm install

DEBUG='*' ./index.js \
    --server='https://www.overviewproject.org' \
    --api-token="$API_TOKEN" \
    file1.txt [file2.doc [file3.pdf [...]]]

curl -XPOST 'https://www.overviewproject.org/api/v1/files/finish' -u "$API_TOKEN:x-auth-token"
```

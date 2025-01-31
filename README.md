# delete-s3-artifact

A GitHub Action for deleting AWS S3 artifacts within the workflow run. This can be useful when artifacts are shared across jobs, but are no longer needed when the workflow is complete.

## Usage

See [action.yml](action.yml)

### Delete an individual artifact

```yml
steps:
    - name: Create test file
      run: echo "hello world!" > test.txt

    - uses: NinjaManatee/upload-s3-artifact@v0.1
      with:
          name: artifact
          path: test.txt

    - uses: NinjaManatee/delete-s3-artifact@main
      with:
          name: artifact
```

### Specify multiple names

```yml
steps:
    - uses: NinjaManatee/delete-s3-artifact@main
      with:
          name: |
              text-artifact-*
              binary-artifact
```

## Error vs Fail

By default, the action will fail when it was not possible to delete an artifact (with the exception of name mismatches). When the deletion of an artifact is not integral to the success of a workflow, it is possible to error without failure. All errors are logged.

```yml
steps:
    - uses: NinjaManatee/delete-s3-artifact@main
      with:
          name: okay-to-keep
          failOnError: false
```
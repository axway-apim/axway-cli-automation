{
    group: "catalog",
    apiVersion: "v1",
    kind: "ReleaseTag",
    metadata: {
        scope: {
            kind: "Product",
            name: .[0].name,
        }
    },
    spec: {
        releaseType: "major"
    }
}
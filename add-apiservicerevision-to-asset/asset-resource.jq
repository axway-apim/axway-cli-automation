{
    apiVersion: "v1alpha1",
    kind: "AssetMapping",
    metadata: {
        scope: {
            kind: "Asset",
            name: "\(.[1].name)"
        }
    },
    spec: {
        inputs: {
          stage: "\(.[2][0].name)",
          apiService: "management/\(.[0].name)/\(.[3][0].name)",
          apiServiceRevision: "management/\(.[0].name)/\(.[4][0].name)"
        }
    }
}
class GraphiphyStats {
  final int nodeCount;
  final int edgeCount;
  final int communityCount;
  final Map<String, int> fileTypes;

  const GraphiphyStats({
    required this.nodeCount,
    required this.edgeCount,
    required this.communityCount,
    required this.fileTypes,
  });

  factory GraphiphyStats.fromJson(Map<String, dynamic> json) {
    return GraphiphyStats(
      nodeCount: json['node_count'] as int? ?? 0,
      edgeCount: json['edge_count'] as int? ?? 0,
      communityCount: json['community_count'] as int? ?? 0,
      fileTypes: (json['file_types'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
    );
  }

}

class GraphiphyGodNode {
  final String label;
  final int degree;
  final int community;
  final String fileType;

  const GraphiphyGodNode({
    required this.label,
    required this.degree,
    required this.community,
    required this.fileType,
  });

  factory GraphiphyGodNode.fromJson(Map<String, dynamic> json) {
    return GraphiphyGodNode(
      label: json['label'] as String? ?? '',
      degree: json['degree'] as int? ?? 0,
      community: json['community'] as int? ?? -1,
      fileType: json['file_type'] as String? ?? 'unknown',
    );
  }
}

class GraphiphyNode {
  final String label;
  final String fileType;
  final int community;
  final String sourceFile;
  final int degree;
  final String id;

  const GraphiphyNode({
    required this.label,
    required this.fileType,
    required this.community,
    required this.sourceFile,
    required this.degree,
    required this.id,
  });

  factory GraphiphyNode.fromJson(Map<String, dynamic> json) {
    return GraphiphyNode(
      label: json['label'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'unknown',
      community: json['community'] as int? ?? -1,
      sourceFile: json['source_file'] as String? ?? '',
      degree: json['degree'] as int? ?? 0,
      id: json['id'] as String? ?? '',
    );
  }
}

class GraphiphyCommunity {
  final int id;
  final int size;
  final List<String> topLabels;

  const GraphiphyCommunity({
    required this.id,
    required this.size,
    required this.topLabels,
  });

  factory GraphiphyCommunity.fromJson(Map<String, dynamic> json) {
    return GraphiphyCommunity(
      id: json['id'] as int? ?? -1,
      size: json['size'] as int? ?? 0,
      topLabels: (json['top_labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

function dataCluster=extractClusterData(clusters)

if ~isempty(clusters)
    for i=1:numel(clusters)
        
    cluster=clusters{i};
    
    dataCluster{i}.metric_value=cluster.metric_value;
    dataCluster{i}.permutations=cluster.permutations;
    dataCluster{i}.nPerm=cluster.nPerm;
    dataCluster{i}.nPermUnique=cluster.nPermUnique;
    dataCluster{i}.endpoints=cluster.endpoints;
    dataCluster{i}.csign=cluster.csign;
    dataCluster{i}.extent=cluster.extent;
    dataCluster{i}.extentR=cluster.extentR;
    dataCluster{i}.h=cluster.h;
    dataCluster{i}.xy=cluster.xy;
    dataCluster{i}.P=cluster.P;
    dataCluster{i}.iswrapped=cluster.iswrapped;
    dataCluster{i}.metric_label=cluster.metric_label;
    dataCluster{i}.metric_value=cluster.metric_value;
    end
else
    dataCluster=[];
end
end
function renderStackedAreaChart(reportResult, size, div) {
		var data = []; // Array of labek,values and values in turn array for label, number
		var xLabels = []; // X-axis grouping label in display order
		var gDown = reportResult.groupingsDown.groupings;	
		for(var i=0;i<gDown.length;i++) {
				var values = [];
				var subGroupings = [];
				data.push({'key':gDown[i].label, 'values': values, subGroupings: subGroupings});
				for(var j=0;j<gDown[i].groupings.length;j++) {
						var labelIndex = xLabels.indexOf(gDown[i].groupings[j].label);
						if(-1 === labelIndex) {
							xLabels.push(gDown[i].groupings[j].label);
							labelIndex = xLabels.length - 1;
						}
						subGroupings.push(labelIndex);	
						values.push([labelIndex, reportResult.factMap[gDown[i].groupings[j].key+'!T'].aggregates[0].value]);
				}
		}
		// NVD3 doesn't like sparse datasets, so insert 0s wherever necessary
		for(var i=0;i<data.length;i++) {
			if(xLabels.length != data[i].subGroupings.length) {
				for(var j=0;j<xLabels.length;j++) {
					if(-1 === data[i].subGroupings.indexOf(j)) {
						data[i].values.splice(j, 0, [j, 0]);	
					}	
				}
			}
		}
		// Default chart setup code from http://nvd3.org/examples/stackedArea.html 
		var chart = nv.models.stackedAreaChart().margin({right: 100}).useInteractiveGuideline(true).rightAlignYAxis(true).showControls(true).clipEdge(true).x(function(d) { return d[0]; }).y(function(d) { return d[1]; });
		chart.xAxis.tickFormat(function(d) { return xLabels[d]}).axisLabel(reportResult.reportExtendedMetadata.groupingColumnInfo[reportResult.reportMetadata.groupingsDown[0].name].label);
		chart.yAxis.axisLabel(reportResult.reportExtendedMetadata.aggregateColumnInfo[reportResult.reportMetadata.aggregates[0]].label); 
		var svg = d3.select(div).append("svg:svg").attr({ "width": size[0], "height": size[1] });
		d3.select("svg").datum(data).call(chart);
};

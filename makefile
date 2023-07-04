BVote:
	mapshaper -i Export_MultiBV/Bvote_Voronoi_Dep_$(NOM).geojson \
	-dissolve2 fields=CODE_BV copy-fields=COMMUNE,INSEE_COM,DEP,nb_bv_commune \
	-o Export_Propre/Bvote_Propre_Dep_$(NOM).geojson

simplifier:
	mapshaper -i Export_Propre/Bvote_Propre_Dep_$(NOM).geojson -simplify 15% -filter-slivers min-area="0.005km2" -o force Export_Propre/Bvote_Propre_Dep_$(NOM).geojson

clean:
	-rm Export_Voronoi/*.geojson

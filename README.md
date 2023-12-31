# Tracer les périmètres des bureaux de vote à partir des adresses des électeurs

### Traitement de l'extrait anonymisé du Répertoire électoral unique, [publié](https://www.data.gouv.fr/fr/datasets/bureaux-de-vote-et-adresses-de-leurs-electeurs/) par l'Insee (version 27/06/2023)


<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/IMG/Appercu_BV.png" width="1000" />

### L’Insee vient de rendre public un [extrait du Répertoire électoral unique (REU)](https://www.data.gouv.fr/fr/datasets/bureaux-de-vote-et-adresses-de-leurs-electeurs/) de l’ensemble du territoire français, daté de septembre 2022. Je publie ici une première version d'un traitement qui permet d'en déduire les périmètres de plus de 69 000 bureaux de vote. Cette méthode produit un premier découpage “acceptable” sous forme de fichiers geojson départementaux.


## Sources :
La méthode que j’utilise ici est adaptée de traitements de listes électorales brutes que j'avais réalisé durant la campagne présidentielle à [Lille](https://www.mediacites.fr/decryptage/lille/2022/06/30/legislatives-nos-cartes-interactives-des-resultats-dans-les-bureaux-de-vote-de-la-mel/), Lyon, Nantes et Toulouse. Elle est inspirée des travaux de l’équipe [Cartelec](http://cartelec.univ-rouen.fr/), d'un [Datacamp CadElect](https://www.etalab.gouv.fr/datacamp-cadelect/) en 2016, auquel avaient participé notamment [Joël Gombin](https://www.linkedin.com/in/jgombin/?originalSubdomain=fr) et [Christian Quest](https://github.com/cquest), d'un article de [Grégory Gibelin](https://makina-corpus.com/sig-webmapping/une-approche-de-reconstruction-automatique-de-la-geometrie-des-bureaux-de-vote), et des conseils experts de [Thomas Gratier](https://www.linkedin.com/in/thomasgratier/?locale=fr_FR).
Avertissement : Le code est à l'image de mon niveau encore limité en python. Toute suggestion d'amélioration est la bienvenue :) 

## Pourquoi le REU est nécessaire
La version intégrale du Répertoire électoral unique contient l’identité (nom, prénom, date et lieu de naissance, nationalité) et l’adresse postale des 48,7 millions d’habitants inscrits sur les listes électorales. Il est alimenté par les communes. Lorsqu’une commune accueille plus d’un millier d’électeurs, il est prévu de les répartir entre plusieurs bureaux de vote, afin de faciliter les opérations électorales. Depuis 2016, cette répartition doit être réalisée selon des critères géographiques. Les maires de chaque commune doivent donc définir un périmètre géographique pour chacun des bureaux. 

Les plus grandes communes, qui disposent d’un service géomatique, ont mis en ligne des fichiers géographiques permettant de cartographier facilement ces bureaux. Mais dans l’immense majorité des cas, les périmètres sont décrits sous forme de texte, avec une simple succession d’adresses, voire par un simple tracé au crayon sur un plan en papier. Les listes électorales offrent donc la meilleure meilleure option si l’on veut visualiser ces périmètres. 
<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/IMG/Exemples_Plans_BV_Mairies.png" width="1000" />


## Pourquoi ce n'est pas aussi magique
Les fichiers geojson créés en sortie (un par département) nécessitent malgré tout une intervention au cas par cas dans un logiciel comme [Qgis](https://www.qgis.org/fr/site/). Car **le résultat est souvent chaotique lorsqu'on zoome sur les limites de bureaux de vote**. Le découpage [proposé par Etalab](https://files.data.gouv.fr/reu/index-reu.html#12.86/47.9042/1.92282), impose d’ailleurs les mêmes corrections a posteriori. Cette limite s’explique principalement par les conditions de production des listes électorales dans chacune des 35 000 communes, et dans une moindre mesure par les erreurs de géolocalisation des adresses. Parfois, des électeurs sont rattachés à un autre bureau de vote que celui correspondant à leur domicile. Il arrive  que des communes conservent des bureaux de vote répartis sur une base alphabétique malgré la réforme de 2016 (c’était encore le cas de Fonsorbes, en Haute-Garonne, à la veille de la présidentielle). Ces cas sont marginaux, mais suffisants pour mettre la pagaille dans un programme. 

<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/IMG/Exemple_Traitement_Etalab.png" width="1000" />


Les choix techniques visent donc d’abord à **limiter le nombre d’erreurs et à obtenir un découpage exploitable en visualisation de données**, pour ainsi “s’approcher” d’une réalité électorale. Après tout, il ne faut pas trop exiger d'un découpage qui a été pensé pour fluidifier le déroulement d’un scrutin électoral et pas pour faire de la sociologie électorale. 

Pour l'instant, ce programme échoue à découper les bureaux de vote de 19 communes, notamment dans les Bouches-du-Rhône à Allauch, Lançon-Provence, Carnoux-en-Provence, Coudoux et Maillane (codes Insee : 13061, 13002, 13118, 13051, 13052 et 13119), et d'autres communes pour lesquelle on trouve les adresses d'un seul bureau de vote (2B311 et 2A141, 07230, 09123, 10112, 30045, 38364, 42272, 55500, 86134, 97356, 97502). Les points d'adresse correspondants à toutes ces communes sont exportés dans un fichier "adresses_communes_erreurs_BV.csv" afin de tenter un découpage visuel dans Qgis.

## La méthode
**En résumé, il s'agit ici de poser les adresses sur une carte puis de dessiner une limite autour de chaque groupe d’adresses appartenant au même bureau de vote.**

<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/IMG/Etapes_Traitement_REU.png" width="1000" />

Dans ce dépôt, vous trouverez un notebook Jupyter, qui fait appel aux librairies [Pandas](https://pandas.pydata.org/), [Geopandas](https://geopandas.org/en/stable/), [Geovoronoi](https://github.com/WZBSocialScienceCenter/geovoronoi), ainsi qu'un fichier "[makefile](https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/makefile)" qui permet d'exécuter des commandes Mapshaper. Cela implique d'installer au préalable [Mapshaper](https://github.com/mbloch/mapshaper/tree/master) en ligne de commande, une librairie javascript que je trouve plus efficace pour certaines opérations.

Voici les opérations exécutées successivement dans le notebook [Perimetres_BV_REU_Etalab_2022.ipynb](https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/Perimetres_BV_REU_Etalab_2022.ipynb) :
- Chargement de l'extrait anonymisé du REU (un fichier csv contenant près de 16 millions de lignes, une par adresse)
- Sélection des 28 229 adresses comprises dans des communes qui ne comprennent qu'un seul bureau de vote : les limites du bureau seront donc celles de la commune...
- On ne conserve que les adresses des 6 762 communes qui comprennent au moins deux bureaux. ce qui représente 11,3 millions de lignes.
- Suppression des erreurs de géolocalisation ou anomalies des listes électorales : Si plusieurs points d'adresses partagent les mêmes coordonnées géographiques mais sont rattachés à des bureaux de vote différents, cela crée une ambiguité lors de la création des diagrammes de voronoï. On choisit donc de supprimer les lignes correspondantes qui rassemblent le moins d'adresse (variable "nb_adresse"). Ce qui supprime 521 308 lignes d'adresses, soit 4,6% du fichier des communes à plusieurs bureaux de vote
- Mais cette opération crée des erreurs à la marge, en supprimant des points d'adresses de bureaux de vote entier dans les petites communes, ce qui bloque l'étape de découpage des communes. On identifie les 9 communes comprenant plusieurs bureaux de vote en théorie, mais avec un seul bureau dans les données, puis on exporte l'ensemble des adresses associées pour tenter ultérierement un découpage en "visuel" dans Qgis. 
- On identifie également les 16 communes dont le nombre de bureaux de vote présents dans les données est inférieur au nombre théorique (il peut s'agir de bureaux "complémentaires", réunissant des électeurs qui n'ont pas de domicile dans la commune, donc sans périmètre géographique, mais on liste quand même ces communes pour vérifier par la suite)
- Afin de réaliser le découpage des bureaux dans les limites administratives des communes, on utilise la base [AdminExpress](https://geoservices.ign.fr/adminexpress) de l'IGN (version juin 2022) : la couche des communes mais aussi celle des arrondissements municipaux pour Paris, Lyon et Marseille.
- Il s'agira ensuite de tracer autour de chaque point d'adresse des [diagrammes de voronoï](https://www.sigterritoires.fr/index.php/analyse-exploratoire-des-donnees-pour-la-geostatistiqueles-diagrammes-de-voronoi/). Une opération qui nécessite de modifier les coordonnées géographique en passant dans un système de projection "world mercator" (epsg:3395).
- Les données sont traitées en boucle par départements, afin d'obtenir des fichiers de sorties plus facile à manipuler, et ménager son ordinateur... J'ai également choisi d'exporter des fichiers aux étapes intermédiaires, afin de faciliter les vérifications ultérieures
- Avant d'exporter le fichier geojson de chaque département, on ajoute les contours des communes qui ne comprennent qu'un seul bureau de vote.
- Chaque fichier départemental est enfin traité avec Mapshaper, en exécutant le fichier makefile : fusion des diagrames de voronoï par bureaux de vote, simplification des contours à 15%, suppression des îlots de moins de 0,005km2. Cette dernière opération peut produire des vides en bordures de certains bureaux de vote, et va donc être revue.


Le fichier "Bvote_Propre_Dep_14.geojson" peut être visualisé rapidement avec l'application en ligne [Kepler.gl](https://kepler.gl/demo). 

L'étape ultime (la plus fastidieuse), consiste à ouvrir chaque fichier geojson dans Qgis pour corriger visuellement les aberrations dans les découpages.

La [méthode proposée par Grégory Gibelin](https://makina-corpus.com/sig-webmapping/une-approche-de-reconstruction-automatique-de-la-geometrie-des-bureaux-de-vote), faisant appel aux tracés de voirie disponibles sur OpenStreetMap, pourrait aussi faciliter ce travail. 


## Pour aller plus loin
La création de ce fond de carte n’a d’intérêt que s’il permet d'y associer les données socio-économiques à l’échelle très fine des Iris, du carroyage de 200m ou du plan cadastral. Ce n’est pas l’objet de ce notebook, mais le travail est en cours et fera l’objet d’une autre publication. C’est le principe de ce croisement de données qui a permis aux géographes du projet Cartelec et notamment à Jean Rivière, de proposer des analyses inédites de la géographie électorale des grandes métropoles françaises. Lire notamment : 
- [“Élections nationales 2022 : pour une analyse localisée du vote et de ses enjeux”](https://metropolitiques.eu/Elections-nationales-2022-pour-une-analyse-localisee-du-vote-et-de-ses-enjeux.html) 
- [“L’illusion du vote bobo. Contre les mystifications géographiques dans l’analyse des votes métropolitains”](https://metropolitiques.eu/L-illusion-du-vote-bobo.html).*

D'autre part, les fichiers obtenus n'autorisent qu'une visualisation des données électorales sous forme de cartes choroplètes. Je ne suis pas persuadé que ce soit le choix graphique le plus pertinent pour représenter des données sociales et les nuances dans les comportements électoraux, notamment parce qu'il entretiennent la contradiction entre la surface des découpages administratifs ruraux et leur poids démographique. Je préfère les cartogrammes de dorling, les semis de points (1 point = 1 électeur) ou encore les cartes dassymétriques (à partir des tâches urbaines, ou de cercles proportionnels à la population), [comme celle-ci](https://public.flourish.studio/visualisation/10435692/) avec les bureaux de vote de la région toulousaine. Mais cela nécessite des traitements complémentaires. La [vidéo publiée par WeDoData](https://twitter.com/we_do_data/status/1675772691113025537) à partir des traitements que j'avais réalisé à Lille montre bien l'intérêt de varier les formes graphiques dans un même projet de visualisation. 

## Avant l'open-data
**La publication par l'Insee de cette base de données doit beaucoup à [Joël Gombin](https://www.linkedin.com/in/jgombin/?originalSubdomain=fr)**, qui a milité dans ce sens dès 2014, et transmis en 2020 la première [demande](https://madada.fr/demande/extraction_de_la_correspondance) officielle d’ouverture des données à l’Insee, organisme qui venait de se voir confier la gestion du REU. Comme d’autres après lui, j’ai eu l’occasion de faire une demande similaire peu avant le scrutin présidentiel de 2022, avec la même [fin de non-recevoir](https://madada.fr/demande/fichier_anonymise_du_repertoire). On peut bien sûr se féliciter de voir ces demandes finalement satisfaites. Mais rien n’interdit de s’étonner encore du temps nécessaire pour anonymiser une extraction du REU. D’autant plus que la seule alternative proposée était se tourner vers les mairies ou les préfectures en demandant une copie intégrale des listes électorales, incluant donc l’identité complète de chaque électeur… 

Car, en effet, **n’importe quel électeur peut obtenir copie de ce document sensible, sous des conditions strictes de confidentialité et d’utilisation non-commerciale**. C’est la voie que j’ai fini par suivre, début 2022, en demandant des copies des listes électorales intégrales dans une quarantaine de départements. Outre la difficulté d’identifer les interlocuteurs directs dans chaque préfecture, cela impliquait de solliciter des services très chargés à l’approche du scrutin. C’était aussi se soumettre à des interprétations très variables du code électoral : le plus souvent, les réponses des préfectures étaient justes et prudentes, mais dans quelques cas, des listes électorales m’ont été transmises par des fonctionnaires avec une légèreté inquiétante s’agissant de données aussi sensibles. Sans compter les cas inévitables de mauvaise volonté manifeste ou d’obstruction de principe mal inspirée. 

Bref, ce sont ces listes électorales complètes qui m’ont permis de **cartographier, il y a un an, l’ensemble des bureaux de votes des aires d’attraction de Nantes, Lille, Lyon, Toulouse et Bordeaux**. Le résultat a été publié dans Médiacités quelques semaines après le second tour des présidentielles, et transmis aux chercheurs qui m’en faisaient la demande. Un travail alors inédit à cette échelle des aires d’attraction :
- [Raz‐de‐marée électoraux, reports de voix au second tour : trois cartes pour mieux comprendre les législatives 2022 à Toulouse](https://www.mediacites.fr/decryptage/toulouse/2022/07/11/raz-de-maree-electoraux-reports-de-voix-au-second-tour-trois-cartes-pour-mieux-comprendre-les-legislatives-2022-a-toulouse/)
- [Législatives en Loire‐Atlantique : un vote polarisé à Nantes et dans la métropole](https://www.mediacites.fr/breve/nantes/2022/07/07/legislatives-en-loire-atlantique-un-vote-polarise-a-nantes-et-dans-la-metropole/)
- [Après les législatives, la nouvelle carte politique de la métropole de Lyon](https://www.mediacites.fr/breve/lyon/2022/07/04/carte-interactive-apres-les-legislatives-la-nouvelle-carte-politique-de-la-metropole-de-lyon/)
- [Législatives : nos cartes interactives des résultats dans les bureaux de vote de la MEL](https://www.mediacites.fr/decryptage/lille/2022/06/30/legislatives-nos-cartes-interactives-des-resultats-dans-les-bureaux-de-vote-de-la-mel/)



<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/IMG/Carte_Legislatives_BV_Lyon.png" width="700" />



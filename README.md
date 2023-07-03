# Tracer les périmètres des bureaux de vote à partir des adresses des électeurs

### Traitement de l'extrait anonymisé du Répertoire électoral unique, [publié](https://www.data.gouv.fr/fr/datasets/bureaux-de-vote-et-adresses-de-leurs-electeurs/) par l'Insee (version 27/06/2023)


<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/APPERCU_BV.png" width="1000" />

### L’Insee vient de rendre public un [extrait du Répertoire électoral unique (REU)](https://www.data.gouv.fr/fr/datasets/bureaux-de-vote-et-adresses-de-leurs-electeurs/) de l’ensemble du territoire français, daté de septembre 2022. Son objectif est ici de déduire les périmètres de plus de 69 000 bureaux de vote, pour lequels il n’existe à ce jour aucun fond de carte exhaustif et exploitable en visualisation de données électorales. Je publie ici une première version d'un traitement qui permet d'obtenir un premier découpage “acceptable” sous forme de fichiers geojson départementaux.

## Sources :
La méthode que j’utilise ici est inspirée des traitements réalisés par l’équipe de [Cartelec](http://cartelec.univ-rouen.fr/), et par ceux exploré lors d'un [Datacamp CadElect](https://www.etalab.gouv.fr/datacamp-cadelect/) en 2016, auquel avaient participé notamment [Joël Gombin](https://www.linkedin.com/in/jgombin/?originalSubdomain=fr), [Christian Quest](https://github.com/cquest), ou encore [Grégory Gibelin](https://makina-corpus.com/sig-webmapping/une-approche-de-reconstruction-automatique-de-la-geometrie-des-bureaux-de-vote), avec quelques conseils experts de Thomas Gratier.

## Pourquoi le REU est nécessaire :
La version intégrale du Répertoire électoral unique contient l’identité (nom, prénom, date et lieu de naissance, nationalité) et l’adresse postale des 48,7 millions d’habitants inscrits sur les listes électorales. Il est alimenté par les communes. Lorsqu’une commune accueille plus d’un millier d’électeurs, il est prévu de les répartir entre plusieurs bureaux de vote, afin de faciliter les opérations électorales. Depuis 2016, cette répartition doit être réalisée selon des critères géographiques (un principé précisé dans une circulaire de 2017 (lien). Les maires de chaque commune doivent donc définir un périmètre géographique pour chacun des bureaux. 

Les plus grandes communes, les plus en avance sur la démarche de données ouvertes, qui disposent d’un service géomatique, ont mis en ligne des fichiers géograqhiques qui permettent de cartographier facilement ces bureaux. Mais l’immense majorité des cas, le périmètre sont décrits sous forme de texte, avec une simple succession d’adresses, voire par un simple tracé au crayon sur un plan en papier. Les listes électorales offrent donc la meilleure meilleure option si l’on veut visualiser ces périmètres. 

## Pourquoi c'est pas magique:
Les fichiers geojson créés en sortie (un par département) nécessitent malgré tout une intervention au cas par cas dans un logiciel comme [Qgis](https://www.qgis.org/fr/site/). Car **le résultat est souvent chaotique lorsqu'on zoome sur les limites de bureaux de vote**. Le découpage [proposé par Etalab](https://files.data.gouv.fr/reu/index-reu.html#12.86/47.9042/1.92282), impose d’ailleurs les mêmes corrections a posteriori. Cette limite s’explique principalement par les conditions de production des listes électorales dans chacune des 35 000 communes, et dans une moindre mesure par les erreurs de géolocalisation des adresses. Parfois, des électeurs sont rattachés à un autre bureau de vote que celui correspondant à leur domicile. Il arrive  que des communes conservent des bureaux de vote répartis sur une base alphabétique malgré la réforme de 2016 (c’était encore le cas de Fonsorbes, en Haute-Garonne, à la veille de la présidentielle). Ces cas sont marginaux, mais suffisants pour mettre la pagaille dans un programme. 

Les choix techniques visent donc d’abord à **limiter le nombre d’erreurs et à obtenir un découpage exploitable en visualisation de données**, pour ainsi “s’approcher” d’une réalité électorale. Après tout, il ne faut pas trop exiger d'un découpage qui a été pensé pour fluidifier le déroulement d’un scrutin électoral et non pour permettre des études de sociologie électorale. N'attendons pas un fond de carte aussi rigoureux et exhaustif que ceux que ceux auxquels nous ont habitué l’IGN et l’Insee. On notera d'ailleurs que l'un comme l'autre ne s'y est pas encore risqué.

## La méthode :
**En résumé, il s'agit ici de poser les adresses sur une carte puis à dessiner une limite autour de chaque groupe d’adresses appartenant au même bureau de vote.**

Dans ce dépôt, vous trouverez un notebook Jupyter, qui fait appel aux librairies [Pandas](https://pandas.pydata.org/), [Geopandas](https://geopandas.org/en/stable/), [Geovoronoi](https://github.com/WZBSocialScienceCenter/geovoronoi), ainsi qu'un fichier "makefile" qui permet d'exécuter des commandes Mapshaper. Cela implique d'installer au préalable [Mapshaper](https://github.com/mbloch/mapshaper/tree/master) en ligne de commande, une librairie javascript que je trouve plus efficace pour certaines opérations.

Voici les opérations exécutées successivement dans le notebook "Perimetres_BV_REU_Etalab_2022.ipynb" :
- Chargement de l'extrait anonymisé du REU (un fichier csv contenant près de 16 millions de lignes, une par adresse)
- Sélection des 28 229 adresses comprises dans des communes qui ne comprennent qu'un seul bureau de vote : les limites du bureau seront donc celles de la commune...
- On ne conserve que les adresses des 6 762 communes qui comprennent au moins deux bureaux. ce qui représente 11,3 millions de lignes.
- Suppression des erreurs de géolocalisation ou anomalies des listes électorales : 171 201 points, situés dans 6 136 communes différentes,qui géolocalisent les adresses d'électeurs de plusieurs bureaux de vote distincts, ainsi que 40 points identiques issus de communes différentes. Cela correspond à 365 151 lignes d'adresses, donc seulement 0,03% des lignes du fichiers des communes à plusieurs bureaux de vote. 
- Mais cette opération crée des erreurs à la marge, en supprimant des points d'adresses de bureaux de vote entier dans les petites communes, ce qui bloque l'étape de découpage des communes.
On commence donc par identifier les 18 communes comprenant plusieurs bureaux de vote en théorie, mais avec un seul bureau dans les données, et 8 autres qui ont généré des erreurs lors des premiers essais de traitements puis on exporte l'ensemble des adresses associées pour tenter ultérierement un découpage en "visuel" dans Qgis. (*Codes Insee : '05063', '06074', '07230', '09123', '10112', '13061', '24515', '2A070', '2A163', '2B147', '2B229', '2B283', '2B311', '38364', '42272', '55500', '86134', '97301', '97502', '30045', '2A141', '13118', '13002', '13051', '13052', '13119'*)
- On identifie également les 35 communes dont le nombre de bureaux de vote présents dans les données est inférieur au nombre théorique (il peut s'agir de bureaux "complémentaires", réunissant des électeurs qui n'ont pas de domicile dans la commune, donc sans périmètre géographique, mais on liste quand même ces communes pour vérifier par la suite)
- Afin de réaliser le découpage des bureaux dans les limites administratives des communes, on utilise la base [AdminExpress](https://geoservices.ign.fr/adminexpress) de l'IGN (version juin 2022) : la couche des communes mais aussi celle des arrondissements municipaux pour Paris, Lyon et Marseille.


Le principe des [diagrammes de voronoï](https://www.sigterritoires.fr/index.php/analyse-exploratoire-des-donnees-pour-la-geostatistiqueles-diagrammes-de-voronoi/) permet d’envisager ce travail de manière automatique avec un programme en python, en javascript ou en R. 



Dans la pratique, on peut tout à fait imaginer que les élus de certaines communes encouragent un découpage suffisamment lisible des bureaux de vote : quand il s’agit de piloter une campagne électorale, il est utile de connaître le profil électoral des habitants d’un quartier. Et, sans cynisme, on peut envisager qu’une connaissance fine de la géographie électorale d’une ville contribue à orienter les choix des programmes urbains durant un mandat. 

## Pour aller plus loin :
La création de ce fond de carte n’a d’intérêt que s’il permet d’associer des données socio-économiques à l’échelle très fine des Iris, du carroyage de 200m ou du plan cadastral. Ce n’est pas l’objet de ce notebook, mais le travail est en cours et fera l’objet d’une autre publication. C’est le principe de ce croisement de données qui a permis aux géographes du projet Cartelec et notamment à Jean Rivière, de proposer des analyses inédites de la géographie électorale des grandes métropoles françaises. Lire notamment : 
- [“Élections nationales 2022 : pour une analyse localisée du vote et de ses enjeux”](https://metropolitiques.eu/Elections-nationales-2022-pour-une-analyse-localisee-du-vote-et-de-ses-enjeux.html) 
- [“L’illusion du vote bobo. Contre les mystifications géographiques dans l’analyse des votes métropolitains”](https://metropolitiques.eu/L-illusion-du-vote-bobo.html).*

## Avant l'open-data...
**La mise à disposition du public de cette base de données doit beaucoup à [Joël Gombin](https://www.linkedin.com/in/jgombin/?originalSubdomain=fr)**, qui a milité dans ce sens dès 2014, et transmis en 2020 la première [demande](https://madada.fr/demande/extraction_de_la_correspondance) officielle d’ouverture des données à l’Insee, organisme qui venait de se voir confier la gestion du REU. Comme d’autres après lui, j’ai eu l’occasion de faire une demande similaire auprès de l’Insee peu avant le scrutin présidentiel de 2022, avec la même [fin de non-recevoir](https://madada.fr/demande/fichier_anonymise_du_repertoire). On peut bien sûr se féliciter de voir ces demandes finalement satisfaites, trois ans plus tard. Mais rien n’interdit de s’étonner encore du temps nécessaire pour anonymiser une extraction du REU. D’autant plus que la seule alternative proposée était se tourner vers les mairies ou les préfectures en demandant une copie intégrale des listes électorales, incluant donc l’identité complète de chaque électeur… 

Car, en effet, **n’importe quel électeur peut obtenir copie de ce document sensible, sous des conditions strictes de confidentialité et d’utilisation non-commerciale**. C’est la voie que j’ai fini par suivre, début 2022, en demandant des copies des listes électorales intégrales dans une quarantaine de départements. Outre la difficulté d’identifer les interlocuteurs directs dans chaque préfecture, cela impliquait de solliciter des services très chargés à l’approche du scrutin. C’était aussi se soumettre à des interprétations très variables du code électoral : le plus souvent, les réponses des préfectures étaient justes et prudentes, mais dans quelques cas, des listes électorales m’ont été transmises par des fonctionnaires avec une légèreté inquiétante s’agissant de données aussi sensibles. Sans compter les cas inévitables de mauvaise volonté manifeste ou d’obstruction de principe mal inspirée. 

Bref, ce sont ces listes électorales complètes qui m’ont permis de **cartographier, il y a un an, l’ensemble des bureaux de votes des aires d’attraction de Nantes, Lille, Lyon, Toulouse et Bordeaux**. Le résultat a été publié dans Médiacités quelques semaines après le second tour des présidentielles, et transmis aux chercheurs qui m’en faisaient la demande. Un travail alors inédit à cette échelle des aires d’attraction :
- [Raz‐de‐marée électoraux, reports de voix au second tour : trois cartes pour mieux comprendre les législatives 2022 à Toulouse](https://www.mediacites.fr/decryptage/toulouse/2022/07/11/raz-de-maree-electoraux-reports-de-voix-au-second-tour-trois-cartes-pour-mieux-comprendre-les-legislatives-2022-a-toulouse/)
- [Législatives en Loire‐Atlantique : un vote polarisé à Nantes et dans la métropole](https://www.mediacites.fr/breve/nantes/2022/07/07/legislatives-en-loire-atlantique-un-vote-polarise-a-nantes-et-dans-la-metropole/)
- [Après les législatives, la nouvelle carte politique de la métropole de Lyon](https://www.mediacites.fr/breve/lyon/2022/07/04/carte-interactive-apres-les-legislatives-la-nouvelle-carte-politique-de-la-metropole-de-lyon/)
- [Législatives : nos cartes interactives des résultats dans les bureaux de vote de la MEL](https://www.mediacites.fr/decryptage/lille/2022/06/30/legislatives-nos-cartes-interactives-des-resultats-dans-les-bureaux-de-vote-de-la-mel/)





### Tracer les périmètres des bureaux de vote à partir des adresses des électeurs 
- Traitement de l'extrait anonymisé du Répertoire électoral unique, publié par l'Insee (version 27/06/2023)
https://www.data.gouv.fr/fr/datasets/bureaux-de-vote-et-adresses-de-leurs-electeurs/

<img src="https://github.com/Denis-Vannier/bureaux-de-vote-2022/blob/main/APPERCU_BV.png" width="900" />

L’Insee vient de rendre public un extrait du Répertoire électoral unique (REU) de l’ensemble du territoire français, daté de 2022. Son objectif est ici de déduire le périmètre des ??? bureaux de vote, pour lequels il n’existe à ce jour aucun fond de carte exhaustif et exploitable en visualisation de données électorales.

Je propose ici une méthode pour obtenir un premier découpage “acceptable”. Le résultat obtenu nécessite une intervention au cas par cas dans un logiciel comme Qgis. Le découpage proposé par Etalab (lien), impose d’ailleurs les mêmes corrections a posteriori. Cette limite s’explique principalement par les conditions de production des listes électorales dans chacune des 35 000 communes, et dans une moindre mesure par les erreurs de géolocalisation des adresses. 

Les choix techniques visent donc d’abord à limiter le nombre d’erreurs et à obtenir un découpage exploitable en visualisation de données, pour ainsi “s’approcher” d’une réalité électorale.

La méthode que j’utilise ici est inspirée des traitements réalisés par l’équipe de Cartelec, et par ceux de Joël Gombin, Christian Quest, ou encore Grégory Gibelin, avec quelques conseils experts de Thomas Gratier.

La version intégrale du REU contient l’identité (nom, prénom, date et lieu de naissance, nationalité) et l’adresse postale des 48,7 millions d’habitants inscrits sur les listes électorales. Il est alimenté par les communes. Lorsqu’une commune accueille plus d’un millier d’électeurs, il est prévu de les répartir entre plusieurs bureaux de vote, afin de faciliter les opérations électorales. Depuis 2016, cette répartition doit être réalisée selon des critères géographiques (un principé précisé dans une circulaire de 2017 (lien). Les maires de chaque commune doivent donc définir un périmètre géographique pour chacun des bureaux. 

Les plus grandes communes, les plus en avance sur la démarche de données ouvertes et qui disposent d’un service géomatique, ont mis en ligne des fichiers géograqhiques qui permettent de cartographier facilement ces bureaux. Mais l’immense majorité des cas, le périmètre sont décrits sous forme de texte, avec une simple succession d’adresses, voire par un simple tracé au crayon sur un plan en papier. 

Les listes électorales offrent donc la meilleure meilleure option si l’on veut visualiser ces périmètres. En résumé, la méthode consiste à poser les adresses sur une carte puis à dessiner une limite autour de chaque groupe d’adresses appartenant au même bureau de vote. Le principe des diagrammes de vornonoï permet d’envigager ce travail de manière automatique en écrivant un programme informatique, en python, en javascript ou en R. Dans la pratique, ce n’est pas aussi magique. Dans certains cas, des électeurs sont rattachés à un autre bureau de vote que celui correspondant à leur domicile. Il arrive même que des communes conservent des bureaux de vote répartis sur une base alphabétique malgré la réforme de 2016 (c’était encore le cas de Fonsorbes, en Haute-Garonne, à la veille de la présidentielle). 

Ces cas sont marginaux, mais suffisants pour mettre la pagaille dans un programme. Dans ces conditions, le plus raisonnable est d’admettre qu’on ne pourra pas obtenir un fond de carte aussi rigoureux et exhaustif qu’un découpage communal, ou par Iris, définis et centralisés par l’IGN ou l’Insee. 

Je suis donc d’avis qu’on ne peut pas automatiser la construction d’un fond de carte utilisable des bureaux de vote à l’échelle nationale. Les visualiser à l’échelle de la France serait d’ailleurs illisible et sans intérêt pour les analyses de sociologie électorale. Au mieux, il s’agit de trouver des astuces qui faciliteront les ajustements, commune par commune. 

Après tout, on ne peut pas exiger de ce découpage ce que l’on attend des Iris : il n’a pas été pensé pour faciliter des études de sociologie mais pour fluidifier le déroulement d’un scrutin électoral. Dans la pratique, on peut tout à fait imaginer que les élus de certaines communes encouragent un découpage suffisamment lisible des bureaux de vote : quand il s’agit de piloter une campagne électorale, il est utile de connaître le profil électoral des habitants d’un quartier. Et, sans cynisme, on peut envisager qu’une connaissance fine de la géographie électorale d’une ville contribue à orienter les choix des programmes urbains durant un mandat. 

Par ailleurs, la création de fond de carte n’a d’intérêt que s’il permet d’associer des données socio-économiques à l’échelle très fine des Iris, du carroyage de 200m ou du plan cadastral, mise à disposition par l’Insee et l’IGN (ce n’est pas l’objet de ce notebook, mais le travail est en cours et fera l’objet d’une autre publication). C’est d’ailleurs le principe de ce croisement de données qui a permis aux géographes du projet Cartelec et notamment à Jean Rivière, de proposer des analyses inédites de la géographie électorale des grandes métropoles françaises. Lire notamment “Élections nationales 2022 : pour une analyse localisée du vote et de ses enjeux” et “L’illusion du vote bobo. Contre les mystifications géographiques dans l’analyse des votes métropolitains”.



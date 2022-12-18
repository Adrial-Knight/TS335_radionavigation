# TS335: Systèmes de navigation par satellites
## Scripts
### Estimation d'une trajectoire
La trajectoire d'un véhicule est estimée avec [traj_Talence.m](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/traj_Talence.m) à partir de données GPS fournies dans le dossier [data](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/data). Comme la trajectoire réelle est également connue, les erreurs commisent par l'algorithme sont évaluaées. La précision selon la disposition des satellites est également mesurée avec la _DOP_ (Dilution Of Presicion).

### Robustesse de l'algorithme
Les données mise en entrée de l'algorithme sont modifiées avec [perturbation.m](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/perturbations.m) afin d'étudier l'influence de perturbations. Deux cas de figure sont considérés:
1. Des interférences avec d'autres signaux. Le caractère aléatoire est lissé en moyennant plusieurs simulations
2. Un biais constant sur les mesures d'un satellite

## Résulats
Les résultats obtenus sont présentés en détails dans le [rapport](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/rapport.md).

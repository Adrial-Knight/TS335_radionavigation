# Systèmes de navigation GPS: Navigation par satellites
<p align="center">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/Logo_ENSEIRB-MATMECA-Bordeaux_INP.svg" width=50% height=50% title="Logo ENSEIRB">
</p>

## Sommaire
[1. Introduction](#introduction)\
[2. Repères utilisés](#reperes-utilises)\
       [2.1 Changement de repère de ECEF à NED](#changement-de-repere-de-ecef-a-ned)\
       [2.2 Point de référence](#point-de-reference)\
[3. Algorithme des moindres carrés](#algorithme-des-moindres-carres)\
       [3.1 Trajectoire du véhicule](#trajectoire-du-vehicule)\
       [3.2 Interférences](#interferences)\
       [3.3 Multi trajets](#multi-trajets)\
[4. Dilution Of Precision (DOP)](#dilution-of-precision)\
       [4.1 Expression de la DOP](#expression-de-la-dop)\
       [4.2 Le long de la trajectoire du véhicule](#le-long-de-la-trajectoire-du-vehicule)\
[5. Conclusion](#conclusion)

## Introduction
La navigation par GPS fait partie des systèmes de navigation dits extéroceptifs, car c'est un système externe au récepteur qui lui permet de déterminer sa position, par opposition aux systèmes dits proprioceptifs.

Dans le cas du GPS, ce sont $24$ satellites qui orbitent autour de la Terre et annoncent à tous les récepteurs dans leur champ de vision leur position ainsi que celle de tous les autres satellites de la constellation.

Le récepteur de son côté compare les signaux reçus par tous les satellites dans son champ de vision, sélectionne les $4$ meilleurs, et se base sur le délai de propagation des messages GPS pour calculer sa position par triangulation.

On se propose dans ce travail d'implémenter un système de positionnement GPS. Ce système est testé pour une trajectoire réalisée dans Talence. Sa résistance aux interférences et aux phénomènes multi-trajets est ensuite testée. Enfin, la Dilution of Precision (DOP) a été évaluée.

## Reperes utilises
Deux repères sont considérés pour ce travail:

       1. ECEF: repère de référence ayant pour origine $O$ le centre de la Terre. Son axe $x$ pointe sur l'intersection du plan de l'ecliptique et du méridien de Greenwich, et son axe $z$ pointe vers le pôle Nord. Son axe $y$ est défini de sorte à former un trièdre direct.
        
       2. NED: repère local dans lequel  le véhicule est localisé. Il se situe à la surface de la Terre, et ses axes pointent à la verticale locale, vers le Nord et vers le Sud. Il est centré sur un point de référence $P_0$.
       
### Changement de repere de ECEF a NED
Pour passer du repère ECEF au repère NED, la matrice de passage suivante est utilisée:

$$
    \mathbf{M} = 
    \begin{bmatrix}
        - \sin\lambda \cos\varphi & - \sin\varphi & - \cos\lambda \cos\varphi \\
        - \sin\lambda \sin\varphi &   \cos\varphi & - \cos\lambda \sin\varphi  \\
        \cos\lambda               &    0          & - \sin\lambda
    \end{bmatrix}
$$

avec $\lambda$ la latitude du point $P_0$, et $\varphi$ sa longitude. Cette matrice $\mathbf{M}$ est obtenue à partir des deux rotations élémentaires décrite sur les figures suivantes:

<p align="center">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/reperes.png" width=70% height=70% title="Les rotations de repères élémentaires">
</p>

La figure de gauche est associée à la matrice de rotation $\mathbf{R}_{ECEF \rightarrow (x'y'z)}$

$$
    \mathbf{R}_{ECEF \rightarrow (x'y'z)} = 
    \left[\begin{array}{cc}
        - \cos\varphi & - \sin\varphi & 0 \\
          \sin\varphi &   \cos\varphi & 0 \\
          0           &   0           & 1 
    \end{array}\right]
$$

Celle de droite à $\mathbf{R}_{(x'y'z) \rightarrow NED}$

$$
    \mathbf{R}_{(x'y'z) \rightarrow NED} = 
    \left[\begin{array}{cc}
        - \sin\lambda & 0 & -\cos\lambda \\
          0           & 1 & 0 \\
          \cos\lambda & 0 & -\sin\lambda 
    \end{array}\right]
$$

Pour obtenir $\mathbf{M}$, il suffit d'appliquer successivement ces deux rotations, c'es-à-dire de multiplier les deux matrices de rotations élémentaires ci-dessus. Finalement, la formule de passage d'un référentiel à l'autre est:

$$
    \mathbf{X}^1 = \mathbf{M}\mathbf{X}^2 + \mathbf{X}_0^1
$$

où $\mathbf{X}^1$ est le point d'intérêt dans le repère NED, $\mathbf{X}^2$ est le même point dans le repère ECEF, et $\mathbf{X}_0^1$ représente les coordonnées de $P_0$ dans le repère ECEF.

### Point de reference
Afin d'estimer la position du véhicule dans le repère local NED, un point de référence permettant de linéariser les calculs est nécessaire. Sa latitude et sa longitude sont fournies, permettant de déterminer ses coordonnées dans le repère local grâce au programme [lh2xyz](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/function/conversion/llh2xyz.m) fourni.

## Algorithme des moindres carres
La trajectoire obtenue par l'algorithme des moindres carrés est représentée en bleu sur la figure ci-dessous dans le repère local NED. La trajectoire réelle du véhicule est tracée à titre de comparaison en orange. Sur certaines parties, les courbes se superposent presque parfaitement, avec des décalages allant jusqu'à 16 mètres.

<p align="center">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/trajectoire_estimee.svg" width=100% height=100% title="Trajectoire réelle et estimée">
</p>

### Trajectoire du vehicule
### Interferences
Pour simuler des [interférences](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/perturbations.m), du bruit de mesure est ajouté aux pseudos distances GPS mesurées et communiquées par les satellites.

Le résultat de ces simulations est donné sur la figure ci-dessous. Le comportement de l'erreur quadratique des mesures réelles et estimées est linéaire pour de fortes variances du bruit de mesure. Comme ajouter des interférences amène de l'aléatoire, la courbe obtenue oscille. Pour y remédier, la simulation a été effectuée 1000 fois puis moyennée. C'est pourquoi la courbe est lissée.

<p align="center">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/interferences.svg" width=75% height=75% title="Influence des interférences">
</p>

### Multi trajets
Pour simuler un [multi-trajet](https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/perturbations.m), un biais de mesure est ajouté aux pseudos distances GPS relevé d'un ou plusieurs satellites. C'est-à-dire qu'un décalage constant est ajouté.

Le résultat est donné sur la prochaine figure. L'erreur évolue quadratiquement avec le biais sur un satellite. Le minimum n'est pas atteint en zéro car les données de référence utilisées doivent avoir un léger biais à l'origine.

<p align="center">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/multi-trajet.svg" width=75% height=75% title="Influence des multi-trajets">
</p>

## Dilution Of Precision
La qualité de la géométrie de la constellation de satellites vue depuis le récepteur a son importance. En effet, si les satellites sont par exemple tous alignés avec le récepteur, il est alors impossible d'estimer la position de la cible; les équations liant les paramètres du vecteur d'état $\mathbf{X}$ sont toutes proportionnelles: le système n'est pas inversible. Ce cas là reste tout de même particulier. La _Dilution Of Precision_ (DOP) est une métrique évaluant les cas intermédiaires.

### Expression de la DOP
La DOP se définit à partir la racine carrée de l'erreur quadratique $RMSE$ commise sur l'estimation du vecteur d'état $\mathbf{X}$ et de l'écart type $\sigma$ du bruit de mesure.

$$
    RMSE = \sigma \times DOP
$$

#### Expression de $\widehat{\mathbf{X}}$
$\widehat{\mathbf{X}}$ est la solution au problème des moindres carrés.

$$
\begin{align}
    \widehat{\mathbf{X}} &= \underset{\mathbf{X}}{\mathrm{argmin}} ||\mathbf{Z} - \mathbf{H}\mathbf{X}||^2 \\
    &= \underset{\mathbf{X}}{\mathrm{argmin}} \left(\mathbf{Z} - \mathbf{H}\mathbf{X}\right)^T\left(\mathbf{Z} - \mathbf{H}\mathbf{X}\right) \\
    &= \underset{\mathbf{X}}{\mathrm{argmin}} \left(\mathbf{Z}^T\mathbf{Z} - 2\mathbf{X}^T\mathbf{H}^T\mathbf{Z} + \mathbf{X}^T\mathbf{H}^T\mathbf{H}\mathbf{X}\right)
\end{align}
$$

La fonction à minimiser de l'expression se dérive selon $\mathbf{X}$. Une fois sa dérivée mise à zéro, un minimseur est obtenu car la dérivée seconde est $2\mathbf{H}^T\mathbf{H}$: une matrice semi-définie positive.

$$
\begin{align}
    \mathbf{0} &= -2\mathbf{H}^T\mathbf{Z} + 2\mathbf{H}^T\mathbf{H}\widehat{\mathbf{X}} \\
    \widehat{\mathbf{X}} &= (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{Z}
\end{align}
$$

#### Expression de l'erreur d'estimation
L'erreur d'estimation est développée dans la suite. Elle permet d'expliciter le RMSE dans le prochain paragraphe.

$$
\begin{align}
   \widehat{\mathbf{X}} - \mathbf{X} &= (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{Z} - \mathbf{X} \\
   &= (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T(\mathbf{H}\mathbf{X} + \mathbf{w}) - \mathbf{X} \\
   &= (\mathbf{H}^T\mathbf{H})^{-1}(\mathbf{H}^T\mathbf{H})\mathbf{X} + (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{w} - \mathbf{X} \\
   &= \mathbf{X} + (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{w} - \mathbf{X} \\
   &= (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{w}
\end{align}
$$

#### Développement du RMSE
En développant la définition du RMSE, on obtient:

$$
\begin{align}
    RMSE &= \sqrt{\\mathbb{E}\left[ ||\mathbf{X} - \widehat{\mathbf{X}}||^2\right]} \\
    &= \sqrt{\mathbb{E}\left[{\Big(\mathbf{X} - \widehat{\mathbf{X}}\Big)\Big(\mathbf{X} - \widehat{\mathbf{X}}\Big)^T}\right]} \\
    &= \sqrt{\mathbb{E}\big[\mathrm{tr}\left((\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T\mathbf{w}\mathbf{w}^T\mathbf{H}(\mathbf{H}^T\mathbf{H})^{-1}\right)\big]} \\
    &= \sqrt{\mathrm{tr}\big((\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T \mathbb{E}[\mathbf{w}\mathbf{w}^T]\mathbf{H}(\mathbf{H}^T\mathbf{H})^{-1}\big)} \\
    &= \sqrt{\sigma^2 \mathrm{tr}\big((\mathbf{H}^T\mathbf{H})^{-1} (\mathbf{H}^T\mathbf{H}) (\mathbf{H}^T\mathbf{H})^{-1}\big)} \\
    &= \sigma \sqrt{\mathrm{tr}\big((\mathbf{H}^T\mathbf{H})^{-1}\big)}
\end{align}
$$

Par identification des termes avec la défintion de la DOP, une formulation explicite pour la $DOP$ est obtenue:

$$
    DOP = \sqrt{\mathrm{tr}\big((\mathbf{H}^T\mathbf{H})^{-1}\big)}
$$


### Le long de la trajectoire du vehicule
La figure à gauche donne les DOP calculés à chaque instant; celle de droite suit les erreurs quadratiques entre les positions du plan $(O, x, y)$ estimées et réelles. Un pic de DOP est obtenu entre les échantillons 600 et 700. Il coïncide avec la perte des données d'un satellite supplémentaire (passant de 7 à 6 sur cette période). Malgré cette perte d'information, l'erreur quadratique est inchangée. On en conclut qu'être dans la vision de 6 ou 7 satellites est ici équivalent.

<p align="middle">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/DOP.svg" width=45% height=45% title="DOP et dérivées">
     <img src="https://github.com/Adrial-Knight/TS335_radionavigation/blob/main/doc/fig/erreur_quadratique.svg" width=45% height=45% title="Erreurs quadratiques">
</p>

## Conclusion
En linéarisant les équations issues de l'algorithme des moindres carrés autour d'un point de référence, il est possible de mettre en oeuvre un programme simple pouvant traiter les données de satellites pour estimer la position d'un véhicule avec une erreur maximale de 16 mètres. Les erreurs quadratiques du traitement développé croissent linéairement avec l'ajout d'interférences et quadratiquement en présence de multi-trajets. Il également possible d'estimer les instants où la constellation des satellites n'est pas optimales avec le calcul de la DOP, sous réserve d'inverser une matrice $(4\times4)$.

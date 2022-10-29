
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : math-adjust-fr.scm
;; DESCRIPTION : adjustments for French speech based on heuristic training
;; COPYRIGHT   : (C) 2022  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (math math-adjust-fr)
  (:use (math math-speech)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disambiguation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (french-de s)
  (with prev (expr-before-cursor)
    (cond ((not prev) (speech-insert-symbol s))
          ((or (and (string? prev) (== (math-symbol-type prev) "symbol"))
               (tm-in? prev '(math-ss math-tt wide wide*))
	       (tm-is? prev 'big)
	       (editing-big-operator?))
           (cond ((editing-big-operator?)
                  (speech-of))
                 ((or (stats-role? `(concat ,prev (rsub ,s)))
                      (stats-role? `(concat ,prev (rsup ,s)))
                      (stats-role? `(concat ,prev (around "(" ,s ")")))
                      (stats-role? `(concat ,prev (around* "(" ,s ")"))))
                  (speech-insert-symbol s))
                 ((or (== s "2")
                      (stats-role? `(concat ,prev (around "(" "" ")")))
                      (stats-role? `(concat ,prev (around* "(" "" ")"))))
                  (speech-of))
                 (else (speech-insert-symbol s))))
          (else (speech-insert-symbol s)))))

(speech-map french math
  ;; psi/xi/6 ambiguity
  ("psi/xi" (speech-insert-best "<psi>" "<xi>"))
  ("psi/xi/6" (speech-best-letter "<psi>" "<xi>" "6"))
  ("psi/xi/6 chapeau" (speech-best-accent "^" "<psi>" "<xi>"))
  ("psi/xi/6 tilde" (speech-best-accent "~" "<psi>" "<xi>"))
  ("psi/xi/6 barre" (speech-best-accent "<bar>" "<psi>" "<xi>"))

  ;; nu/9 ambiguity
  ("nu/9" (speech-best-letter "<nu>" "9"))
  ("nu/9 chapeau" (speech-best-accent "^" "<nu>"))
  ("nu/9 tilde" (speech-best-accent "~" "<nu>"))
  ("nu/9 barre" (speech-best-accent "<bar>" "<nu>"))

  ;; 2/de and related ambiguities
  ("2/de" (french-de "2"))
  ("d/de" (french-de "d"))
  ("t/de" (french-de "t"))

  ;; 8/i ambiguity
  ("i/8" (speech-best-letter "i" "8"))

  ;; 4/k ambiguity
  ("k/4" (speech-best-letter "k" "4"))

  ;; a/e/i and related ambiguities
  ("a/a" (speech-insert-best "a")) ;; prevent problems with "a n", "a p", ...
  ("a/e" (speech-insert-best "a" "e"))
  ("e/a" (speech-insert-best "e" "a"))
  ("e/i" (speech-insert-best "e" "i"))

  ;; b/d/p/t and related ambiguities
  ("b/d" (speech-insert-best "b" "d"))
  ("b/d/p" (speech-insert-best "b" "d" "p"))
  ("b/p" (speech-insert-best "b" "p"))
  ("d/b" (speech-insert-best "d" "b"))
  ("p/b" (speech-insert-best "p" "b"))
  ("p/t" (speech-insert-best "p" "t"))
  ("t/d" (speech-insert-best "t" "d"))

  ;; g/j ambiguity
  ("g/j" (speech-insert-best "g" "j"))

  ;; i/y ambiguity
  ("y/i" (speech-insert-best "y" "i"))

  ;; m/n ambiguity
  ("m/n" (speech-insert-best "m" "n"))
  ("n/m" (speech-insert-best "n" "m"))

  ;; other ambiguities
  ("g/v" (speech-insert-best "g" "v"))
  ("l/n" (speech-insert-best "l" "n"))
  ("u/i" (speech-insert-best "u" "i"))
  ("u/o" (speech-insert-best "u" "o"))
  ("v/e" (speech-insert-best "v" "e"))
  ("w/v" (speech-insert-best "w" "v"))
  )

(speech-reduce french math
  ("psi/xi/6 de" "psi/xi de")
  ("nu/9 de" "nu de")
  ("psi/xi/6 prime" "psi/xi prime")
  ("nu/9 prime" "nu prime")
  ("psi/xi/6 rond" "psi/xi rond")
  ("nu/9 rond" "nu rond")
  ("rond psi/xi/6" "rond psi/xi")
  ("rond nu/9" "rond nu")

  ("une" "un")
  ("en" "un")
  ("si" "psi/xi")
  )

(speech-adjust french math
  ("qu'à" "k")
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tables to adjust recognition of mathematics inside text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(speech-collection dangerous french
  ;; latin letters
  "sait" "des" "eux" "œuf" "gay" "âge" "hache" "il" "ils"
  "j'y" "car" "cas" "casse" "aile" "ailes" "elle" "aime"
  "au" "beau" "eau" "eaux" "haut" "os" "paye" "pays" "air" "est-ce"
  "t'es" "taille" "tes" "eu" "vais" "value" "vert"

  ;; greek letters
  "bâtard" "gamin" "éteins" "est" "atteint" "état" "tata"
  "mou" "mieux" "mur" "mûr" "mus" "nue" "nul" "pile" "pis"
  "euro" "euros" "robe" "robot" "rock" "rome" "rose" "rouge"
  "auto" "tôt" "taux" "options" "fille" "fit" "qui"

  ;; letter combinations
  "assez" "haï" "haïti" "agit" "agen" "arènes" "août"
  "appeler" "appelle" "happer" "athée" "avez"
  "béat" "bébé" "baisser" "bédé" "bide" "déesse" "gaité"
  "dévérrouiller" "acheter" "achevé" "cassé" "canapé" "capter"
  "hello" "hélix" "hausser" "noël" "ôter" "paysan" "paysannes"
  "cruel" "couper" "occuper" "cousin" "respect" "rester"
  "yuen" "butter" "lutter" "buvez" "veggie" "vécu" "véhicule"
  "vérité" "fixer" "exiger" "pixels" "exo" "excuse" "issue"
  "fixette" "zappé"

  ;; punctuation
  "tel" "telle"

  ;; operators 'plus', 'moins', 'fois'
  "opus" "pupuce" "moi" "monter" "noisette" "manteau"
  "foie" "fort" "photo" "photos"

  ;; composition 'rond'
  "rang" "rend" "irons" "giron" "caron" "aileron" "huron" "verrons"
  "ranger" "ronger" "rompez" "remonter"

  ;; predicates 'égal'
  "égalité" "également"
  
  ;; operators and function application
  "dette" "bédé" "idée" "rodé" "décès"
 
  ;; fractions
  "sûr" "assure" "culture" "mesure" "chaussure" "chaussures"
  "surgé" "surveille" "sureau" "surtout"

  ;; wide accents
  "chapeaux" "utile" "utilité" "bars" "bar"

  ;; particularly dangerous adjustments
  "a" "à" "ai" "ce" "dans" "de" "deux" "en"
  "le" "la" "ne" "on" "se" "si"
  "ta" "te" "the" "un" "une")

(speech-collection skip-start french
  "ce" "dans" "est" "est-ce" "le" "la" "ne" "on" "se" "ta" "te")

(speech-collection skip-end french
  "ce" "dans" "est" "est-ce" "le" "la" "ne" "on" "se" "ta" "te")

(speech-collection skip french
  "et" "ma" "ou")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Adjust wrongly recognized words
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(speech-adjust french math
  ;; Adjust latin letters
  ("ah" "a")
  ("a-ha" "a")
  ("bae" "b")
  ("bébé" "b")
  ("ben" "b")
  ("bye" "b")
  ("c'est" "c")
  ("sait" "c")
  ("say" "c")
  ("day" "d")
  ("des" "d/de")
  ("dès" "d")
  ("eux" "e")
  ("œuf" "f")
  ("j'ai" "g")
  ("j'est" "g")
  ("gay" "g")
  ("âge" "h")
  ("ashe" "h")
  ("hache" "h")
  ("aïe" "i")
  ("il" "i")
  ("ils" "i")
  ("caca" "k")
  ("car" "k")
  ("cara" "k")
  ("cas" "k")
  ("casse" "k")
  ("kaaris" "k")
  ("j'y" "j")
  ("aile" "l")
  ("ailes" "l")
  ("el" "l")
  ("elle" "l")
  ("aime" "m")
  ("aisne" "n")
  ("haine" "n")
  ("and" "n")
  ("au" "o")
  ("beau" "o")
  ("eau" "o")
  ("eaux" "o")
  ("haut" "o")
  ("homepod" "o")
  ("oh" "o")
  ("os" "o")
  ("paye" "p")
  ("pays" "p")
  ("cul" "q")
  ("her" "r")
  ("air" "r")
  ("est-ce" "s")
  ("stay" "t")
  ("t'es" "t")
  ("taille" "t")
  ("tes" "t")
  ("eu" "u")
  ("hue" "u")
  ("û" "u")
  ("vais" "v")
  ("vay" "v")
  ("value" "v")
  ("vert" "v")
  ("vii" "v")
  ("that" "z")
  ("zed" "z")

  ;; Adjust greek letters
  ("bâtard" "beta")
  ("beata" "beta")
  ("bertin" "beta")
  ("bêta" "beta")
  ("bête un" "beta")
  ("bête a" "beta")
  ("bête à" "beta")
  ("betta" "beta")
  ("d'état" "beta")
  ("camas" "gamma")
  ("gama" "gamma")
  ("gamard" "gamma")
  ("gamin" "gamma")
  ("kama" "gamma")
  ("k ma" "gamma")
  ("epsylon" "epsilon")
  ("silone" "epsilon")
  ("si l'homme" "epsilon")
  ("vous êtes a" "zeta")
  ("vous êtes à" "zeta")
  ("za" "zeta")
  ("zaatar" "zeta")
  ("zelda" "zeta")
  ("zêta" "zeta")
  ("atteint" "eta")
  ("est un" "eta")
  ("est a" "eta")
  ("est à" "eta")
  ("est tard" "eta")
  ("et ta" "eta")
  ("et t'as" "eta")
  ("êta" "eta")
  ("état" "eta")
  ("éteins" "eta")
  ("êtes a" "eta")
  ("êtes à" "eta")
  ("insta" "eta")
  ("greta" "eta")
  ("pétard" "theta")
  ("tata" "theta")
  ("teta" "theta")
  ("tête a" "theta")
  ("tête à" "theta")
  ("têtard" "theta")
  ("thêta" "theta")
  ("tintin" "theta")
  ("t'es a" "theta")
  ("t'es à" "theta")
  ("t'es pas" "theta")
  ("t'es t'as" "theta")
  ("ciotat" "iota")
  ("yo t'as" "iota")
  ("yota" "iota")
  ("cap a" "kappa")
  ("cap à" "kappa")
  ("capa" "kappa")
  ("qu'à pas" "kappa")
  ("lakhdar" "lambda")
  ("lanta" "lambda")
  ("lampe a" "lambda")
  ("lampe à" "lambda")
  ("lampe ta" "lambda")
  ("lampe tard" "lambda")
  ("lampe torche" "lambda")
  ("lampe t'as" "lambda")
  ("lent a" "lambda")
  ("lent à" "lambda")
  ("lomepal" "lambda")
  ("mieux" "mu")
  ("mou" "mu")
  ("mur" "mu")
  ("mûr" "mu")
  ("mubi" "mu")
  ("mumu" "mu")
  ("mus" "mu")
  ("nue" "nu")
  ("nul" "nu")
  ;;("si" "xi")
  ("au micro" "omicron")
  ("au micro en" "omicron")
  ("aux migrants" "omicron")
  ("haut microns" "omicron")
  ("pie" "pi")
  ("pile" "pi")
  ("pis" "pi")
  ("pipi" "pi")
  ("euro" "rho")
  ("euros" "rho")
  ("raux" "rho")
  ("rhô" "rho")
  ("robe" "rho")
  ("robot" "rho")
  ("rock" "rho")
  ("roh" "rho")
  ("rome" "rho")
  ("rose" "rho")
  ("roue" "rho")
  ("rouge" "rho")
  ("row" "rho")
  ("c'est ma" "sigma")
  ("chic ma" "sigma")
  ("cinéma" "sigma")
  ("cite-moi" "sigma")
  ("cite-moi un" "sigma")
  ("si ma" "sigma")
  ("site ma" "sigma")
  ("sigmar" "sigma")
  ("sixma" "sigma")
  ("auto" "tau")
  ("taux" "tau")
  ("to" "tau")
  ("toe" "tau")
  ("tony" "tau")
  ("tôt" "tau")
  ("town" "tau")
  ("options" "upsilon")
  ("upside down" "upsilon")
  ("ypsilon" "upsilon")
  ("fille" "phi")
  ("fit" "phi")
  ("psy" "psi")
  ;;("si" "psi")
  ("qui" "chi")
  ("oméga" "omega")

  ;; Adjust case
  ("granda" "grand a")
  ("grand deux" "grand e")
  ("grand dash" "grand h")
  ("grande arche" "grand h")
  ("grandi" "grand i")
  ("grand tel" "grand l")
  ("grandel" "grand l")
  ("grand haine" "grand n")
  ("quarantaine" "grand n")
  ("canto" "grand o")
  ("grand haut" "grand o")
  ("grand o 2/de" "grand o de")
  ("grand torino" "grand o")
  ("grande ou" "grand o")
  ("grandeau" "grand o")
  ("grando" "grand o")
  ("rando" "grand o")
  ("grandeur" "grand r")
  ("grandesse" "grand s")
  ("grandu" "grand u")
  ("grand dix" "grand x")
  ("grandi grec" "grand y")
  ("grandy" "grand y")
  ("rangama" "grand gamma")
  ("grand états" "grand zeta")
  ("grand état" "grand theta")
  ("i gotta" "grand iota")
  ("grand lampe" "grand lambda")
  ("grand mut" "grand mu")
  ("quand omicron" "grand omicron")
  ("grand pays" "grand pi")
  ("grand amphi" "grand phi")

  ;; Adjust latin letter combinations
  ("assez" "a c")
  ("a f" "a/e f")
  ("ah oui" "a i")
  ("ai" "a i")
  ("aie" "a i")
  ("aïe" "a i")
  ("haï" "a i")
  ("haïti" "a i")
  ("agit" "a i")
  ("a j" "a/e j")
  ("ak" "a/e k")
  ("aka" "a/a k")
  ("al" "a/e l")
  ("a m" "a/e m")
  ("a n" "a/e n")
  ("an" "a/e n")
  ("agen" "a/a n")
  ("arènes" "a n")
  ("la haine" "a n")
  ("août" "a o")
  ("a p" "a/e p")
  ("app" "a/a p")
  ("apple" "a/a p")
  ("appeler" "a/a p")
  ("appelle" "a/a p")
  ("happer" "a/a p")
  ("a q" "a/e q")
  ("a r" "a/e r")
  ("ar" "a/a r")
  ("a s" "a/e s")
  ("as" "a/a s")
  ("maes" "a s")
  ("a t" "a/e t")
  ("athée" "a/a t")
  ("avez" "a v")
  ("a w" "a/e w")
  ("a y" "a/e y")
  ("a z" "a/e z")
  ("béa" "b a")
  ("béat" "b a")
  ("léa" "b a")
  ("bébé" "b/d b")
  ("baisser" "b c")
  ("bédé" "b d")
  ("bid" "b d")
  ("bide" "b d")
  ("b f" "b/d f")
  ("b h" "b/d h")
  ("baby" "b i")
  ("bailey" "b i")
  ("benji" "b j")
  ("b b l" "b l")
  ("b p" "b/d p")
  ("mets q" "b q")
  ("b t/de s" "b s")
  ("becter" "b t")
  ("mets u" "b/d/p u")
  ("b m w" "b v")
  ("b x" "b/d x")
  ("b z" "b/p z")
  ("c'est des" "c d")
  ("c'est des" "c d")
  ("c d/de i" "c i")
  ("c'est aime" "c m/n")
  ("c'est où" "c o")
  ("c'était" "c t")
  ("dis à" "d a")
  ("dis siri" "d c")
  ("des œuf" "d/b e")
  ("des œufs" "d/b e")
  ("d f" "d/b f")
  ("daily" "d/b i")
  ("dave" "d i")
  ("d k" "d/b k")
  ("déca" "d k")
  ("d l" "d/b l")
  ("des ailes" "d/b l")
  ("d m" "d m/n")
  ("d s" "d/b s")
  ("déesse" "d s")
  ("d'été" "d t")
  ("gaité" "d t")
  ("des v" "d/b v")
  ("dévé" "d v")
  ("dévérrouiller" "d v")
  ("div" "d v")
  ("mets x" "d x")
  ("d y" "d/b y")
  ("ea" "e a")
  ("ee" "e e")
  ("ei" "e i")
  ("eij" "e i j")
  ("ek" "e k")
  ("eo" "e o")
  ("es" "e s")
  ("e.t." "e/i t")
  ("ex" "e x")
  ("f.a." "f a")
  ("f g" "f g/j")
  ("f.i." "f i")
  ("f.o." "f o")
  ("f.u." "f u")
  ("g c" "g/v c")
  ("j'ai des" "g d")
  ("gie" "g/j e")
  ("gégé" "g g")
  ("gigi" "g j")
  ("j'ai quatre" "g k/4")
  ("gen" "g n")
  ("géhenne" "g n")
  ("g s" "g/j s")
  ("g t/de" "g/j t/de")
  ("j'ai eu" "g/j u")
  ("j'ai w" "g/j w")
  ("g x" "g/j x")
  ("g y" "g/v y")
  ("jay-z" "g z")
  ("h e" "h e")
  ("h a h" "h h")
  ("hi" "h i")
  ("machika" "h k")
  ("rachel" "h l")
  ("aachen" "h n")
  ("ho" "h o")
  ("sache que" "h q")
  ("acheter" "h t")
  ("achevé" "h v")
  ("ah je vais" "h v")
  ("hiv" "h v")
  ("ia" "i a")
  ("ebay" "i b")
  ("ie" "i e")
  ("i.e." "i e")
  ("ii" "u/i i")
  ("ikea" "i k")
  ("io" "i o")
  ("iu" "i u")
  ("jia" "j a")
  ("je" "j e")
  ("ji" "j i")
  ("j m" "j m/n")
  ("gio" "j o")
  ("gsx" "j x")
  ("carla" "k a")
  ("cardi b" "k b")
  ("cassé" "k c")
  ("karma" "k e/a")
  ("k f c" "k f")
  ("cash" "k h")
  ("kaash" "k h")
  ("kai" "k i")
  ("kygo" "k i")
  ("kylie" "k i")
  ("gaël" "k l")
  ("canem" "k m")
  ("cahen" "k n")
  ("caren" "k n/m")
  ("karen" "k n/m")
  ("chaos" "k o")
  ("canapé" "k p")
  ("capet" "k p")
  ("carpe" "k p")
  ("capter" "k t")
  ("quarter" "k t")
  ("cavez" "k v")
  ("kaz" "k z")
  ("el ars" "l a")
  ("la" "l a")
  ("le" "l e")
  ("appelle f" "l f")
  ("appelle g" "l g")
  ("l g" "l g/j")
  ("appelle h" "l h")
  ("appelle m" "l m/n")
  ("l m" "l m/n")
  ("hello" "l o")
  ("l homme" "l o")
  ("l p" "l p/b")
  ("elle était" "l t")
  ("appelle w" "l w")
  ("helix" "l x")
  ("hélix" "l x")
  ("eligrek" "l y")
  ("a l z" "l z")
  ("emma" "m a")
  ("ma" "m a")
  ("m b" "m/n b")
  ("m c" "m/n c")
  ("m d/de" "m/n d/de")
  ("m f" "m/n f")
  ("mah" "m h")
  ("am i" "m i")
  ("m l" "m/n l")
  ("m m" "m n/m")
  ("m p" "m/n p")
  ("m q" "m/n q")
  ("m r" "m/n r")
  ("m v" "m/n v")
  ("m w" "m/n w")
  ("m y" "m/n y")
  ("m z" "m/n z")
  ("and est" "n d")
  ("ne" "n e")
  ("angers" "n g")
  ("i n g" "n g")
  ("angie" "n j")
  ("no" "n o")
  ("and que" "n q")
  ("henvez" "n v")
  ("p m w" "n/m w")
  ("oa" "o a")
  ("obey" "o b")
  ("obi" "o b")
  ("kobe" "o b")
  ("hausser" "o c")
  ("o d d/de" "o d")
  ("holy" "o i")
  ("how i" "o i")
  ("o g g y" "o j")
  ("oh j" "o j")
  ("oh ji" "o j")
  ("ok" "o k")
  ("noël" "o l")
  ("o m" "o n/m")
  ("on" "o n")
  ("uno" "o o")
  ("hope" "o p")
  ("ôter" "o t")
  ("ooouuu" "o u")
  ("beauvais" "o v")
  ("bové" "o v")
  ("over" "o v/e")
  ("p a" "p a/e")
  ("pib" "p b")
  ("p d" "p/t d")
  ("pédé" "p d")
  ("p s g" "p g")
  ("pij" "p j")
  ("p m" "p m/n")
  ("pin" "p n")
  ("p n l" "p n")
  ("pépé" "p p")
  ("p s" "p/b s")
  ("péter" "p t")
  ("péhu" "p u")
  ("p y" "p/b y")
  ("pays aide" "p z")
  ("paysan" "p z")
  ("paysannes" "p z")
  ("cusset" "q c")
  ("que j'ai" "q g")
  ("q.i." "q i")
  ("cugy" "q j")
  ("kukka" "q k")
  ("cruel" "q l")
  ("q m" "q m/n")
  ("tu aimes" "q m/n")
  ("couper" "q p")
  ("occuper" "q p")
  ("putées" "q t")
  ("quix" "q x")
  ("cousin" "q z")
  ("cuzé" "q z")
  ("hergé" "r g")
  ("n r j" "r j")
  ("eren" "r n")
  ("haircuts" "r q")
  ("rtl" "r t")
  ("r t/de l" "r t")
  ("terter" "r t")
  ("ruru" "r u")
  ("r.u." "r u")
  ("hervé" "r v")
  ("raw" "r w")
  ("se" "s e")
  ("est ce" "s e")
  ("s g" "s g/j")
  ("s c h" "s h")
  ("esso" "s o")
  ("respect" "s p")
  ("est-ce que" "s q")
  ("rester" "s t")
  ("s t/de p" "s t")
  ("stp" "s t")
  ("sy" "s y")
  ("ta" "t a")
  ("tdb" "t b")
  ("t d/de b" "t b")
  ("te" "t e")
  ("t h" "t/d h")
  ("iti" "t i")
  ("taylor" "t i")
  ("ti" "t i")
  ("tiji" "t j")
  ("t k" "t/d k")
  ("hatik" "t k")
  ("tpm" "t m")
  ("t/d p m" "t m")
  ("théo" "t o")
  ("t'es où" "t o")
  ("t p" "t/d p")
  ("t'as un cul" "t q")
  ("t'as une cul" "t q")
  ("t s" "t/d s")
  ("t t" "d/t t")
  ("t'es où" "t u")
  ("t v" "t/d v")
  ("ua" "u a")
  ("uber" "u b")
  ("luce" "u c")
  ("u.d" "u d/b")
  ("rue des" "u d")
  ("ue" "u e")
  ("hugés" "u g")
  ("u g c" "u g")
  ("ugc" "u g")
  ("u.g" "u g")
  ("u.i" "u i")
  ("hulk" "u i")
  ("u.j" "u j")
  ("luca" "u k")
  ("lucas" "u k")
  ("u.k" "u k")
  ("u.l" "u l")
  ("u m" "u m/n")
  ("u.m" "u m/n")
  ("yuen" "u n")
  ("u.n" "u n")
  ("huot" "u o")
  ("u.p" "u p")
  ("du cul" "u q")
  ("u.q" "u q")
  ("u.r" "u r")
  ("butter" "u t")
  ("lutter" "u t")
  ("u.t" "u t")
  ("huuh" "u u")
  ("u.u" "u u")
  ("buvez" "u v")
  ("u.v" "u v")
  ("huawei" "u w")
  ("u.w" "u w")
  ("où x" "u x")
  ("u.x" "u x")
  ("u.y" "u y")
  ("uzic" "u z")
  ("u.z" "u z")
  ("vih" "v h")
  ("veggie" "v j")
  ("végy" "v j")
  ("v p n" "v n")
  ("vpn" "v n")
  ("vip" "v p")
  ("fais cul" "v q")
  ("vécu" "v q")
  ("véhicule" "v q")
  ("v v s" "v s")
  ("vvs" "v s")
  ("vérité" "v t")
  ("vété" "v t")
  ("fais eu" "v u")
  ("véhut" "v u")
  ("v&v" "v v")
  ("félix" "v x")
  ("vixx" "v x")
  ("w a" "w/v a/e")
  ("w c" "w/v c")
  ("wtf" "w f")
  ("w t/de f" "w f")
  ("w t/de f" "w f")
  ("w l j" "w j")
  ("wlj" "w j")
  ("win" "w n")
  ("wylix" "w x")
  ("x.a" "x a")
  ("kikesa" "x a")
  ("bixby" "x b")
  ("fixer" "x c")
  ("icsee" "x c")
  ("exiger" "x g")
  ("x.h" "x h")
  ("x.i" "x i")
  ("sik-k" "x k")
  ("x l" "x l/n")
  ("pixels" "x l/n")
  ("exo" "x o")
  ("ixzo" "x o")
  ("excuse" "x q")
  ("issue" "x u")
  ("xix" "x x")
  ("x.x" "x x")
  ("fixette" "x z")
  ("y a" "y/i a")
  ("ye" "y e")
  ("y g" "y g/j")
  ("yih yah" "y h")
  ("y l" "y l/n")
  ("y o" "y o")
  ("cette i" "z i")
  ("cergy" "z j")
  ("zetchi" "z j")
  ("z k r" "z k")
  ("zkr" "z k")
  ("je t'aime" "z m/n")
  ("vous êtes aime" "z m/n")
  ("zen" "z n")
  ("vous êtes p" "z p")
  ("zappé" "z p")
  ("vous êtes cul" "z q")
  ("cet air" "z r")
  ("z k r" "z r")
  ("zkr" "z r")
  ("vous êtes où" "z u/o")
  ("cette vie" "z v")
  ("vous êtes fait" "z v")
  ("vous êtes vais" "z v")
  ("z fait" "z v")
  ("celtics" "z x")
  ("vous êtes x" "z x")
  ("z eats" "z x")

  ;; Adjust miscellaneous symbols and constants
  ("constante dans une heure" "constante d'euler")
  ("constante de eyelar" "constante d'euler")

  ;; Adjust addition 'plus'
  ("capucel" "k plus l")
  ("en plus" "n plus")
  ("au plus" "o plus")
  ("au plus près" "o plus p")
  ("en haut plus" "o plus")
  ("opus" "o plus")
  ("pute plus cul" "p plus q")
  ("pupuce" "q plus")
  ("que plus" "q plus")
  ("t plus plus" "t plus u")
  ("d' plus" "delta plus")
  ("mets plus" "mu plus")
  ("ne plus" "nu plus")
  ("neuf plus" "nu/9 plus")
  ("gros plus" "rho plus")
  ("si plus" "psi/xi plus")
  ("six plus" "psi/xi/6 plus")
  ("youssef" "plus f")
  ("plusi" "plus i")
  ("plus cher" "plus r")
  ("plus spée" "plus p")
  ("plus d'" "plus delta")
  ("plus mieux" "plus mu")
  ("plus neuf" "plus nu/9")
  ("plus si" "plus psi/xi")
  ("plus six" "plus psi/xi/6")
  
  ;; Adjust subtraction 'moins'
  ("moi" "moins")
  ("dis-moi" "d moins")
  ("e-moi" "e moins")
  ("f-moi" "f moins")
  ("j'ai-moi" "g moins")
  ("h-moi" "h moins")
  ("i-moi" "i moins")
  ("k-moi" "k moins")
  ("l-moi" "l moins")
  ("elle-moi" "l moins")
  ("m-moi" "m moins")
  ("aime-moi" "m moins")
  ("o-moi" "o moins")
  ("au-moi" "o moins")
  ("au mois" "o moins")
  ("r-moi" "r moins")
  ("est-ce-moi" "s moins")
  ("témoin" "t moins")
  ("allume moi" "u moins")
  ("allume-moi" "u moins")
  ("du moins" "u moins")
  ("fais-moi" "v moins")
  ("w-moi" "w moins")
  ("y-moi" "y moins")
  ("z-moi" "z moins")
  ("delta-moi" "delta moins")
  ("epsilon-moi" "delta moins")
  ("faites moi" "theta moins")
  ("faites-moi" "theta moins")
  ("pète-moi" "theta moins")
  ("pétard-moi" "theta moins")
  ("theta-moi" "theta moins")
  ("thêta-moi" "theta moins")
  ("iota-moi" "iota moins")
  ("kappa-moi" "kappa moins")
  ("lambda-moi" "lambda moins")
  ("mets-moi" "mu moins")
  ("mu-moi" "mu moins")
  ("neuf moins" "nu/9 moins")
  ("omicron-moi" "omicron moins")
  ("rho-moi" "rho moins")
  ("rose-moi" "rho moins")
  ("sigma one" "sigma moins")
  ("tau-moi" "tau moins")
  ("toe-moi" "tau moins")
  ("file-moi" "phi moins")
  ("fille-moi" "phi moins")
  ("film-moi" "phi moins")
  ("si moins" "psi/xi moins")
  ("six moins" "psi/xi/6 moins")
  ("qui-moi" "qui moins")
  ("oméga-moi" "omega moins")
  ("moinsi" "moins i")
  ("moinsi-moi" "moins i moins")
  ("monter" "moins t")
  ("moinsw" "moins w")
  ("moinsy" "moins y")
  ("moins aide" "moins z")
  ("moins bête" "moins beta")
  ("moins bête a" "moins beta")
  ("moins bête à" "moins beta")
  ("noisette" "moins zeta")
  ("moins ai pas" "moins eta")
  ("moins êtes" "moins eta")
  ("moins êtes a" "moins eta")
  ("moins êtes à" "moins eta")
  ("mon tel éteint" "moins theta")
  ("moins de tête" "moins theta")
  ("moins de tête a" "moins theta")
  ("moins de tête à" "moins theta")
  ("moins tête" "moins theta")
  ("moins tête a" "moins theta")
  ("moins tête à" "moins theta")
  ("moins neuf" "moins nu/9")
  ("moins un pays" "moins pi")
  ("moins gros" "moins rho")
  ("moins un rot" "moins rho")
  ("manteau" "moins tau")
  ("moins si" "moins psi/xi")
  ("moins six" "moins psi/xi/6")
  ("monkey" "moins chi")
  ("moins un chi" "moins chi")

  ;; Adjust multiplication 'fois'
  ("foie" "fois")
  ("fort" "fois")
  ("à chaque fois" "h fois")
  ("hey fois" "p fois")
  ("t une fois" "t fois")
  ("t'es une fois" "t fois")
  ("rue fois" "u fois")
  ("lampe tafua" "lambda fois")
  ("mets fois" "mu fois")
  ("meuf à" "mu fois")
  ("meuf fois" "mu fois")
  ("neuf fois" "nu/9 fois")
  ("rho de fois" "rho fois")
  ("si fois" "psi/xi fois")
  ("six fois" "psi/xi/6 fois")
  ("foisa" "fois i")
  ("fois 10" "fois d")
  ("fois deux" "fois d")
  ("fois 2/de" "fois d")
  ("fois quatre" "fois k")
  ("foisi" "fois i")
  ("fois on" "fois o")
  ("fois où" "fois o")
  ("foiso" "fois o")
  ("foisu" "fois u")
  ("fadel tard" "fois delta")
  ("fois neuf" "fois nu/9")
  ("fois si" "fois psi/xi")
  ("fois six" "fois psi/xi")
  ("fois zéro" "fois rho")
  ("photo" "fois tau")
  ("photos" "fois tau")

  ;; Adjust multiplication 'croix'
  ("croisette" "fois zeta")

  ;; Adjust composition operator 'rond'
  ("rang" "rond")
  ("rend" "rond")
  ("ron" "rond")
  ("run" "rond")
  ("aaron" "a rond")
  ("beyoncé" "b rond c")
  ("irons" "i rond")
  ("giron" "j rond")
  ("caron" "k rond")
  ("aileron" "l rond")
  ("huron" "u rond")
  ("véron" "v rond")
  ("verrons" "v rond")
  ("rondé" "rond d")
  ("ranger" "rond g")
  ("ronger" "rond g")
  ("ron ginny" "rond j")
  ("rongie" "rond j")
  ("ronca" "rond k")
  ("rompez" "rond p")
  ("remonter" "rond t")
  ("ranvée" "rond v")
  ("ranger z" "rond z")

  ;; Adjust predicates 'égal'
  ("égale" "égal")
  ("égal à jusqu'à" "égal un jusqu'à")
  ("fais gaffe" "f égal")
  ("huit égal" "i égal")
  ("dix égal" "de i égal")
  ("10 égal" "de i égal")
  ("quatre égal" "k égal")
  ("elle est égal" "l égal")
  ("un égal un" "n égal un")
  ("ou égal" "u égal")
  ("je v égal" "v égal")
  ("bête égal" "beta égal")
  ("vous êtes égal" "zeta égal")
  ("tête égal" "theta égal")
  ("ferme ta égal" "lambda égal")
  ("neuf égal" "nu/9 égal")
  ("si égal" "psi/xi égal")
  ("six égal" "psi/xi/6 égal")
  ("qui est égal" "chi égal")
  ("égalité" "égal t")
  ("égal bête à" "égal beta")
  ("égal bête a" "égal beta")
  ("égal bête" "égal beta")
  ("égal tête à" "égal theta")
  ("égal tête a" "égal theta")
  ("égal tête" "égal theta")
  ("également" "égal mu")
  ("égal neuf" "égal nu/9")
  ("est galaxie" "égal xi")
  ("et galaxie" "égal xi")
  ("égal si" "égal psi/xi")
  ("égal six" "égal psi/xi/6")

  ;; Adjust punctuation
  ("telle" "tel")
  ("tel qu'" "tel que")
  ("a-t-elle" "a tel")
  (". diagonaux" "points diagonaux")
  (". montant" "points montants")

  ;; Adjust various other operations
  ("un factoriel" "n factoriel")

  ;; Adjust operators
  ("dette" "det")
  
  ;; Adjustments for the polyvalent word 'de'
  ("d'un" "de un")
  ("d'un sur" "de un sur")
  ("the" "de")
  ("bédé" "b de")
  ("belle des" "b de")
  ("c'est des" "c de")
  ("d'aider" "d de")
  ("j'ai des" "g de")
  ("j'ai des aide" "g de z")
  ("j'aide" "g de")
  ("j'ai dit" "g de")
  ("j'ai w w" "g de w")
  ("idée" "i d/de")
  ("j'y d" "j de")
  ("qu'à de" "k de")
  ("qu'à 2/de" "k de")
  ("elle d" "l d/de")
  ("un d" "n de")
  ("cul des" "q de")
  ("que des" "q de")
  ("est-ce d" "s de")
  ("ac/dc" "s de c")
  ("u d x" "u de x")
  ("qu'à mad" "gamma de")
  ("gamin d" "gamma d/de")
  ("epsilon d" "epsilon d/de")
  ("zeta d" "zeta d/de")
  ("iota a de" "iota de")
  ("iota d" "iota d/de")
  ("kappa d" "kappa d/de")
  ("lambda d" "lambda d/de")
  ("medics" "mu de x")
  ("mieux des aides" "mu de z")
  ("mu d" "mu d/de")
  ("nu d" "nu d/de")
  ("omicron d" "omicron d/de")
  ("au micro-ondes" "omicron de")
  ("road" "rho de")
  ("rodè" "rho de")
  ("rodé" "rho de")
  ("rho de 2/de" "rho de")
  ("site mad" "sigma de")
  ("upsilon d" "upsilon d/de")
  ("chi d" "chi d/de")
  ("omega d" "omega d/de")
  ("décès" "de c")
  ("dédé" "de d")
  ("des cailles" "de k")
  ("décale" "de k")
  ("ducat" "de k")
  ("du cul" "de q")
  ("dévé" "de v")
  ("des aides" "de z")
  ("de êtes" "de eta")
  ("décapas" "de kappa")
  ("the road" "de rho")

  ;; Adjust subscripts
  ("un 10" "indice")
  ("un dix" "indice")

  ;; Adjust powers and superscripts
  ("au carré" "carré")
  ("est carré" "carré")
  ("chaos carré" "k carré")
  ("k o carré" "k carré")
  ("ko carré" "k carré")
  ("quatre au carré" "k/4 carré")
  ("huit au carré" "i/8 carré")

  ;; Adjust big operators
  ("sam" "somme")
  ("some" "somme")
  ("sonne" "somme")
  ("somme des" "somme de")
  ("samedi" "somme de i")
  ("someday" "somme de")
  ("somme d'y" "somme de i")
  ("de contours" "contour")
  ("the contours" "contour")
  ("intégrale de un sur" "intégrale un sur")

  ;; Sugar for big operators
  ("d'a à" "de a jusqu'à")
  ("d'à à" "de a jusqu'à")
  ("d'a jusqu'à" "de a jusqu'à")
  ("d'à jusqu'à" "de a jusqu'à")
  ("de zéro a" "de zéro jusqu'à")
  ("de zéro à" "de zéro jusqu'à")
  ("de un a" "de un jusqu'à")
  ("de un à" "de un jusqu'à")
  ("de deux a" "de deux jusqu'à")
  ("de deux à" "de deux jusqu'à")
  ("égal zéro a" "égal zéro jusqu'à")
  ("égal zéro à" "égal zéro jusqu'à")
  ("égal un a" "égal un jusqu'à")
  ("égal un à" "égal un jusqu'à")
  ("égal deux a" "égal deux jusqu'à")
  ("égal deux à" "égal deux jusqu'à")

  ;; Adjust fractions
  ("sûr" "sur")
  ("assure" "a sur")
  ("belle sur" "b sur")
  ("dis sur" "d sur")
  ("bref sur" "f sur")
  ("qu'à sur" "k sur")
  ("bien sûr" "n sur")
  ("ou sûr" "o sur")
  ("où sûr" "o sur")
  ("culture" "q sur")
  ("bus sur" "u sur")
  ("zappe sur" "z sur")
  ("tête sur" "theta sur")
  ("je t'assure" "zeta sur")
  ("but sur" "mu sur")
  ("mesure" "mu sur")
  ("mets sur" "mu sur")
  ("nous sur" "nu sur")
  ("neuf sur" "nu/9 sur")
  ("si sur" "xi sur")
  ("omicron de sur" "omicron sur")
  ("rond sur" "rho sur")
  ("site massures" "sigma sur")
  ("autosur" "tau sur")
  ("chaussures" "tau sur")
  ("si sur" "psi/xi sur")
  ("six sur" "psi/xi/6 sur")
  ("ok sur" "chi sur")
  ("sur ces" "sur c")
  ("sur ses" "sur c")
  ("sur siri" "sur c")
  ("surgé" "sur g")
  ("sur elle" "sur l")
  ("sur aisne" "sur n")
  ("sur on" "sur o")
  ("sur où" "sur o")
  ("sur que" "sur q")
  ("sur terre" "sur r")
  ("sur veille" "sur v")
  ("surveille" "sur v")
  ("suzette" "sur zeta")
  ("sur neuf" "sur nu/9")
  ("sur que si" "sur xi")
  ("sûr que si" "sur xi")
  ("sur tilles" "sur pi")
  ("sureau" "sur rho")
  ("surtout" "sur tau")
  ("sur si" "sur psi/xi")
  ("sur six" "sur psi/xi/6")

  ;; Adjust wide hats
  ("chapo" "chapeau")
  ("chapeaux" "chapeau")
  ("quatre chapeau" "k chapeau")
  ("ou chapeau" "u chapeau")
  ("veille chapeau" "v chapeau")
  ("vieille chapeau" "v chapeau")
  ("six chapeau" "psi chapeau")

  ;; Adjust wide tildas
  ("bathilde" "b tilde")
  ("the tilde" "e tilde")
  ("ou tilde" "o tilde")
  ("est tilde" "s tilde")
  ("ti tilde" "t tilde")
  ("utile" "u tilde")
  ("utilité" "u tilde")
  ("veille tilde" "v tilde")
  ("vieille tilde" "v tilde")
  ("gars mathilde" "gamma tilde")

  ;; Adjust wide bars
  ("bars" "barre")
  ("bar" "barre")
  ("bahr" "barre")
  ("var" "barre")
  ("ibar" "i barre")
  ("gibard" "j barre")
  ("khabar" "k barre")
  ("mbar" "m barre")
  ("au bar" "o barre")
  ("herbart" "r barre")
  ("esbart" "s barre")
  ("hubbard" "u barre")
  ("vieil bar" "w barre")
  ("lampe tabar" "lambda barre")
  ("bibar" "pi barre")
  ("bibard" "pi barre")
  ("tibar" "pi barre")
  ("tibard" "pi barre")
  ("pivar" "pi barre") 
  ("pivard" "pi barre")
  ("robar" "rho barre")
  ("robart" "rho barre")
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Further, more dangerous adjustments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(speech-adjust french math
  ("six barre" "psi barre")
  ("d' sur" "delta sur")
  )

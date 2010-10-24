unitDef = {
  unitname            = [[spherecloaker]],
  name                = [[Eraser]],
  description         = [[Cloaker/Jammer Walker]],
  acceleration        = 0.12,
  activateWhenBuilt   = true,
  brakeRate           = 0.16,
  buildCostEnergy     = 421,
  buildCostMetal      = 421,
  builder             = false,
  buildPic            = [[spherecloaker.png]],
  buildTime           = 421,
  canAttack           = false,
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  canstop             = [[1]],
  category            = [[LAND UNARMED]],
  corpse              = [[DEAD]],

  customParams        = {
    description_bp = [[Robô camuflador e gerador de interfer?ncia.]],
    description_fi = [[N?kym?tt?myyskent?n luova tutkanh?iritsij?robotti]],
    description_fr = [[Marcheur Brouille/Camoufleur]],
    description_pl = [[Robot Maskuj?cy/Zak?ucaj?cy]],
    helptext       = [[The Eraser has a jamming device to conceal your units' radar returns. It also has a small cloak shield to hide friendly nearby units from enemy sight.]],
    helptext_bp    = [[Geradores de interfer?ncia como estes interferem com as ondas de radar inimigas, impedindo a localizaç?o das unidades protegidas. Alguns s?o capazes de gerar falsos sinais de radar.]],
    helptext_fi    = [[Eraser kykenee piilottamaan muut yksikk?si vastustajaltasi h?iritsem?ll? t?m?n tutkasignaalia ja luomalla pienen n?kym?tt?myyskent?n ymp?rilleen.]],
    helptext_fr    = [[L'Eraser est munis d'un brouilleur d'onde qui permet de cacher vos unités des radars enemis. Il est aussi munis d'un petit bouclier de camouflage qui permet de cacher vos unités du champ de vision enemis]],
    helptext_pl    = [[Eraser wyposa?ony jest w urz?dzenie zak?ucaj?ce, które pozwala ukry? twoje jednostki przed wrogim radarem. Posiada tak?e ma?? tarcz? maskuj?c?, która ukrywa pobliskie jednostki przed wzrokiem wroga.]],
  },

  defaultmissiontype  = [[Standby]],
  energyUse           = 1.5,
  explodeAs           = [[BIG_UNITEX]],
  footprintX          = 2,
  footprintZ          = 2,
  iconType            = [[walkerjammer]],
  idleAutoHeal        = 5,
  idleTime            = 1800,
  maneuverleashlength = [[640]],
  mass                = 196,
  maxDamage           = 600,
  maxSlope            = 36,
  maxVelocity         = 1.9,
  maxWaterDepth       = 22,
  minCloakDistance    = 100,
  movementClass       = [[KBOT2]],
  moveState           = 0,
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK]],
  objectName          = [[spherecloaker.s3o]],
  onoffable           = true,
  pushResistant       = 1,
  radarDistanceJam    = 550,
  seismicSignature    = 16,
  selfDestructAs      = [[BIG_UNITEX]],
  side                = [[ARM]],
  sightDistance       = 400,
  smoothAnim          = true,
  steeringmode        = [[1]],
  TEDClass            = [[KBOT]],
  turninplace         = 0,
  turnRate            = 1047,
  workerTime          = 0,

  featureDefs         = {

    DEAD  = {
      description      = [[Wreckage - Eraser]],
      blocking         = true,
      category         = [[corpses]],
      damage           = 600,
      energy           = 0,
      featureDead      = [[DEAD2]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 1,
      footprintZ       = 1,
      height           = [[40]],
      hitdensity       = [[100]],
      metal            = 168.4,
      object           = [[spherebot_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 168.4,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    DEAD2 = {
      description      = [[Debris - Eraser]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 600,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 1,
      footprintZ       = 1,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 168.4,
      object           = [[debris2x2c.s3o]],
      reclaimable      = true,
      reclaimTime      = 168.4,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP  = {
      description      = [[Debris - Eraser]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 600,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 1,
      footprintZ       = 1,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 84.2,
      object           = [[debris2x2a.s3o]],
      reclaimable      = true,
      reclaimTime      = 84.2,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ spherecloaker = unitDef })

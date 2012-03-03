# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'

##____________________________________________________________________________||
class AlgorithmManager
  attr_accessor :geometryManager
  attr_accessor :inDDLInOrderOfAddition
  attr_accessor :entityDisplayer
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @inDDLInOrderOfAddition = Array.new

    # @entityDisplayer = EntityDisplayer.new('algorithm', -200.m, 0, 0)
    @eraseAfterDefine = true
  end
  def clear
    @entityDisplayer.clear
  end
  def addInDDL baseName, args
    inDDL = {:baseName => baseName, :args => args}
    @inDDLInOrderOfAddition << inDDL
  end
  def moveInstanceAway(instance)
    @entityDisplayer.display instance
    instance.erase! if @eraseAfterDefine
    instance
  end

  def exec ddl
    baseName = ddl[:baseName]
    args = convertArguments(ddl)
    if args['name'] == "hcal:DDHCalBarrelAlgo"
      exec_DDHCalBarrelAlgo(baseName, args)
    else
      p "unknown Algorighm name #{args['name']}"
    end
  end
  def convertArguments ddl
    baseName = ddl[:baseName]
    args = ddl[:args]
    ret = Hash.new
    args.each do |k, v|
      if k == 'name'
        ret[k] = v
      elsif k == 'rParent'
        ret[k] = v[0]['name']
      elsif k == 'Numeric'
        v.each { |e| ret[e['name']] = $constantsManager.inSU(baseName, e['value']) }
      elsif k == 'String'
        v.each { |e| ret[e['name']] = e['value'] }
      elsif k == 'Vector'
        v.each do |e|
          entry = e["entry"].gsub(/\r/," ").gsub(/\n/," ")
          entry = entry.split(",").map { |ee| ee.strip }
          if e['type'] == 'numeric'
            entry = entry.map {|ee| $constantsManager.inSU(baseName, ee) }
          end
          ret[e['name']] = entry
        end
      else
        p "unknown key #{k}"
      end
    end
    ret
  end
  def exec_DDHCalBarrelAlgo baseName, args
    ntot = 15
    alpha = Math::PI/args["NSector"]
    dphi  = args["NSectorTot"]*Math::PI*2/args["NSector"]
    nsec = args["NHalf"] == 1 ? 8 : 15
    nf = ntot - nsec
    zoff = args["ZOff"]
    zmax = zoff[3]
    zstep5 = zoff[4]
    zstep4 = zoff[1] + args['RMax'][1]*Math::tan(args['Theta'][1])
    if zoff[2] + args['RMax'][1]*Math::tan(args['Theta'][2]) > zstep4
      zstep4 = zoff[2] + args['RMax'][1]*Math::tan(args['Theta'][2])
    end
    zstep3 = zoff[1] + args['RMax'][0]*Math::tan(args['Theta'][1])
    zstep2 = zoff[0] + args['RMax'][0]*Math::tan(args['Theta'][0])
    zstep1 = zoff[0] + args['RIn']*Math::tan(args['Theta'][0])
    rout   = args['ROut']
    rout1  = args['RMax'][3]
    rin = args['RIn']
    rmid1 = args['RMax'][0]
    rmid2 = args['RMax'][1]
    rmid3 = zoff[4] - zoff[2]/Math::tan(args['Theta'][2])
    rmid4 = args['RMax'][2]

    pgonZ = [-zmax, -zstep5, -zstep5, -zstep4, -zstep3, -zstep2, -zstep1, 0, zstep1, zstep2, zstep3, zstep4, zstep5, zstep5, zmax]
    pgonRmin = [rmid4, rmid3, rmid3, rmid2, rmid1, rmid1, rin, rin, rin, rmid1, rmid1, rmid2, rmid3, rmid3, rmid4]
    pgonRmax = [rout1, rout1, rout, rout, rout, rout, rout, rout, rout, rout, rout, rout, rout, rout1, rout1]

    pgonZHalf = [0, zstep1, zstep2, zstep3, zstep4, zstep5, zstep5, zmax]
    pgonRminHalf = [rin, rin, rmid1, rmid1, rmid2, rmid3, rmid3, rmid4]
    pgonRmaxHalf = [rout, rout, rout, rout, rout, rout, rout1, rout1]
 

    model = Sketchup.active_model
    entities = model.entities

    idNameSpace = baseName
    idName = args['MotherName'].to_sym
    if nf == 0
      solidArgs = Hash.new
      solidArgs['startPhi'] = -alpha
      solidArgs['deltaPhi'] = dphi
      solidArgs['numSide'] = args["NSectorTot"]
      solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax, }}
      solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, idName
      solid.argsInSU = solidArgs
      @geometryManager.solidsManager.addPart idNameSpace, idName, solid
    else
      p 'not implemented'
    end

    materialBaseName, materialName = baseNameName(baseName, args['MaterialName'])

    genlogic = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, idName
    genlogic.solid = solid
    genlogic.materialBaseName = materialBaseName
    genlogic.materialName = materialName
    @geometryManager.logicalPartsManager.addPart idNameSpace, idName, genlogic
    genlogic.definition

    parent = @geometryManager.logicalPartsManager.get(*baseNameName(baseName, args['rParent']))
    pospart = PosPart.new @geometryManager, :PosPart, baseName
    pospart.parent = parent
    pospart.child = genlogic
    @geometryManager.posPartsManager.addPart pospart
    pospart.exec

    name = (idName.to_s + "Half").to_sym
    nf = (ntot + 1)/2

    solidArgs = Hash.new
    solidArgs['startPhi'] = -alpha
    solidArgs['deltaPhi'] = dphi
    solidArgs['numSide'] = args["NSectorTot"]
    solidArgs["ZSection"] = pgonZHalf.zip(pgonRminHalf, pgonRmaxHalf).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
    solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, name
    solid.argsInSU = solidArgs
    @geometryManager.solidsManager.addPart idNameSpace, name, solid

    genlogich = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, name
    genlogich.solid = solid
    genlogich.materialBaseName = materialBaseName
    genlogich.materialName = materialName
    @geometryManager.logicalPartsManager.addPart idNameSpace, name, genlogich
    genlogich.definition

    pospart = PosPart.new @geometryManager, :PosPart, baseName
    pospart.parent = genlogic
    pospart.child = genlogich
    @geometryManager.posPartsManager.addPart pospart
    pospart.exec

    if not args["NHalf"] == 1
      rot = $geometryManager.rotationsManager.get(*baseNameName(args['RotNameSpace'], args['RotHalf']))
      pospart = PosPart.new @geometryManager, :PosPart, baseName
      pospart.parent = genlogic
      pospart.child = genlogich
      pospart.rotation = rot.transformation
      @geometryManager.posPartsManager.addPart pospart
      pospart.exec
    end

    name = (idName.to_s + "Module").to_sym
    solidArgs = Hash.new
    solidArgs['startPhi'] = -alpha
    solidArgs['deltaPhi'] = 2*alpha
    solidArgs['numSide'] = 1
    solidArgs["ZSection"] = pgonZHalf.zip(pgonRminHalf, pgonRmaxHalf).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
    solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, name
    solid.argsInSU = solidArgs
    @geometryManager.solidsManager.addPart idNameSpace, name, solid

    seclogic = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, name
    seclogic.solid = solid
    seclogic.materialBaseName = materialBaseName
    seclogic.materialName = materialName
    @geometryManager.logicalPartsManager.addPart idNameSpace, name, seclogic

    (0..(args['NSectorTot']-1)).each do |ii|
      phi = ii*2*alpha
      rotation = Geom::Transformation.new
      if not phi == 0
        rotstr = "R%03d" % phi.radians.round
        rotation = $geometryManager.rotationsManager.get(*baseNameName(args['RotNameSpace'], rotstr)).transformation
      end
      pospart = PosPart.new @geometryManager, :PosPart, baseName
      pospart.parent = genlogich
      pospart.child = seclogic
      pospart.rotation = rotation
      @geometryManager.posPartsManager.addPart pospart
      pospart.exec
    end

    constructInsideSector(baseName, args, seclogic)


  end

  def constructInsideSector baseName, args, sector
    idNameSpace = baseName
    idName = args['MotherName'].to_sym

    alpha = Math::PI/args["NSector"]
    rin = args['RIn']
    (0..(args['NLayers']-1)).each do |i|
      name = (idName.to_s + args['LayerLabel'][i]).to_sym
      materialBaseName, materialName = baseNameName(baseName, args['LayerMat'][i])
      width = args['LayerWidth'][i]
      rout = rin + width

      iin = 0
      out = 0
      (0..(args['RZones']-2)).each do |j|
        iin = j + 1 if rin >= args['RMax'][j]
        out = j + 1 if rout > args['RMax'][j]
      end
      zout = args['ZOff'][iin] + rin*Math::tan(args['Theta'][iin])

      deltaz = 0
      nsec = 2

      pgonZ = Array.new
      pgonRmin = Array.new
      pgonRmax = Array.new

      pgonZ << 0
      pgonRmin << rin
      pgonRmax << rout

      pgonZ << zout
      pgonRmin << rin
      pgonRmax << rout

      if iin == out
        if iin <= 3
          pgonZ << args['ZOff'][iin] + rout*Math::tan(args['Theta'][iin])
          pgonRmin << pgonRmax[1]
          pgonRmax << pgonRmax[1]
          nsec += 1
        end
      else
        if iin == 3
          pgonZ[1] = args['ZOff'][out] + args['RMax'][out]*Math::tan(args['Theta'][out])
          pgonZ << pgonZ[1] + deltaz
          pgonRmin << pgonRmin[1]
          pgonRmax << args['RMax'][iin]
          pgonZ << args['ZOff'][iin] + args['RMax'][iin]*Math::tan(args['Theta'][iin])
          pgonRmin << pgonRmin[2]
          pgonRmax << pgonRmax[2]
          nsec += 2
        else
          pgonZ << args['ZOff'][iin] + args['RMax'][iin]*Math::tan(args['Theta'][iin])
          pgonRmin << args['RMax'][iin]
          pgonRmax << pgonRmax[1]
          nsec += 1
          if iin == 0
            pgonZ << args['ZOff'][out] + args['RMax'][iin]*Math::tan(args['Theta'][out])
            pgonRmin << pgonRmin[2]
            pgonRmax << pgonRmax[2]
            nsec += 1
          end
          if iin <= 1
            pgonZ << args['ZOff'][out] + rout*Math::tan(args['Theta'][out])
            pgonRmin << rout
            pgonRmax << rout
            nsec += 1
          end
        end
      end

      alpha1 = alpha
      if args['Gap'][i] >  10**(-6)
        rmid = 0.5*(rin + rout)
        width = rmid*Math::tan(alpha) - args['Gap'][i]
        alpha1 = Math::atan(width/rmid)
      end

      solidArgs = {'numSide' => 1, 'startPhi' => -alpha1, 'deltaPhi' => 2*alpha1}
      solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
      solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, name
      solid.argsInSU = solidArgs
      @geometryManager.solidsManager.addPart idNameSpace, name, solid

      glog = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, name
      glog.solid = solid
      glog.materialBaseName = materialBaseName
      glog.materialName = materialName
      @geometryManager.logicalPartsManager.addPart idNameSpace, name, glog

      pospart = PosPart.new @geometryManager, :PosPart, baseName
      pospart.parent = sector
      pospart.child = glog
      @geometryManager.posPartsManager.addPart pospart
      pospart.exec


      constructInsideLayers(baseName, args, glog, args['LayerLabel'][i], args['Id'][i], args['AbsL'][i], 
                            rin, args['D1'][i], alpha1, args['D2'][i], args['Alpha2'][i],
                            args['T1'][i], args['T2'][i])


      rin = rout
    end
  end

  def constructInsideLayers(baseName, args, laylog, nm, id, nAbs, rin, d1, alpha1, d2, alpha2, t1, t2)
    idNameSpace = baseName
    idName = args['MotherName'].to_sym

    rot = $geometryManager.rotationsManager.get(*baseNameName(args['RotNameSpace'], args['DetRot'])).transformation
    name0 = nm + "In" 
    name = (idName.to_s + name0).to_sym
    materialBaseName, materialName = baseNameName(baseName, args['DetMat'])

    if alpha1 > 0
      rsi = rin + d1
      iin = 0
      (0..(args['RZones']-2)).each do |i|
        iin = i + 1 if rsi >= args['RMax'][i]
      end
      dx = 0.5*t1
      dy = 0.5*rsi*(Math::tan(alpha1) - Math::tan(alpha2))
      dz = 0.5*(args['ZOff'][iin] + rsi*Math::tan(args['Theta'][iin]))
      x  = rsi + dx
      y  = 0.5*rsi*(Math::tan(alpha1) + Math::tan(alpha2))
      r11 = Geom::Transformation.translation(Geom::Vector3d.new(dz, x, y))
      r12 = Geom::Transformation.translation(Geom::Vector3d.new(dz, x, -y))

      solid = BasicSolid.new @geometryManager, :Box, idNameSpace, "#{name}1".to_sym
      solid.argsInSU = {"dz"=>dz, "dx"=>dx, "dy"=>dy}
      @geometryManager.solidsManager.addPart idNameSpace, "#{name}1".to_sym, solid

      glog = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, "#{name}1".to_sym
      glog.solid = solid
      glog.materialBaseName = materialBaseName
      glog.materialName = materialName
      @geometryManager.logicalPartsManager.addPart idNameSpace, "#{name}1".to_sym, glog

      if nAbs == 0
        mother = laylog
      else
        mother = constructSideLayer(baseName, args, laylog, name, nAbs, rin, alpha1)
      end

      pospart = PosPart.new @geometryManager, :PosPart, baseName
      pospart.parent = mother
      pospart.child = glog
      pospart.translation = r11
      @geometryManager.posPartsManager.addPart pospart
      pospart.exec

      pospart = PosPart.new @geometryManager, :PosPart, baseName
      pospart.parent = mother
      pospart.child = glog
      pospart.translation = r12
      pospart.rotation = rot
      @geometryManager.posPartsManager.addPart pospart
      pospart.exec

      # p "#{name}, #{i}, #{iin}, #{out}"
      # p pgonZ.map { |p| p.to_l.to_s }

    end

    rsi = rin + d2
    iin = 0
    (0..(args['RZones']-2)).each do |i|
      iin = i + 1 if rsi >= args['RMax'][i]
    end
    dx = 0.5*t2
    dy = 0.5*rsi*Math::tan(alpha2)
    dz = 0.5*(args['ZOff'][iin] + rsi*Math::tan(args['Theta'][iin]))
    x  = rsi + dx
    r21 = Geom::Transformation.translation(Geom::Vector3d.new(dz, x, dy))
    r22 = Geom::Transformation.translation(Geom::Vector3d.new(dz, x, -dy))

    solid = BasicSolid.new @geometryManager, :Box, idNameSpace, "#{name}2".to_sym
    solid.argsInSU = {"dz"=>dz, "dx"=>dx, "dy"=>dy}
    @geometryManager.solidsManager.addPart idNameSpace, "#{name}2".to_sym, solid

    glog = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, "#{name}2".to_sym
    glog.solid = solid
    glog.materialBaseName = materialBaseName
    glog.materialName = materialName
    @geometryManager.logicalPartsManager.addPart idNameSpace, "#{name}2".to_sym, glog

    if nAbs < 0
      mother = constructMidLayer(baseName, args, laylog, name, rin, alpha1)
    else
      mother = laylog
    end

    pospart = PosPart.new @geometryManager, :PosPart, baseName
    pospart.parent = mother
    pospart.child = glog
    pospart.translation = r21
    @geometryManager.posPartsManager.addPart pospart
    pospart.exec

    pospart = PosPart.new @geometryManager, :PosPart, baseName
    pospart.parent = mother
    pospart.child = glog
    pospart.translation = r22
    pospart.rotation = rot
    @geometryManager.posPartsManager.addPart pospart
    pospart.exec

  end

  def constructSideLayer(baseName, args, laylog, nm, nAbs, rin, alpha)
    idNameSpace = baseName
    idName = args['MotherName'].to_sym

    k = nAbs.abs - 1;
    namek = (nm.to_s + 'Side').to_sym
    rsi = rin + args['SideD'][k]
    iin  = 0
    (0..(args['RZones']-2)).each do |i|
      iin = i + 1 if rsi >= args['RMax'][i]
    end

    pgonZ = Array.new
    pgonRmin = Array.new
    pgonRmax = Array.new

    pgonZ << 0
    pgonRmin << rsi
    pgonRmax << rsi + args['SideT'][k]

    pgonZ << args['ZOff'][iin] + rsi*Math::tan(args['Theta'][iin])
    pgonRmin << rsi
    pgonRmax << pgonRmax[0]

    pgonZ << args['ZOff'][iin] + pgonRmax[0]*Math::tan(args['Theta'][iin])
    pgonRmin << pgonRmax[1]
    pgonRmax << pgonRmax[1]

    solidArgs = {'numSide' => 1, 'startPhi' => -alpha, 'deltaPhi' => 2*alpha}
    solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
    solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, namek
    solid.argsInSU = solidArgs
    @geometryManager.solidsManager.addPart idNameSpace, namek, solid

    materialBaseName, materialName = baseNameName(baseName, args['SideMat'][k])

    glog = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, namek
    glog.solid = solid
    glog.materialBaseName = materialBaseName
    glog.materialName = materialName
    @geometryManager.logicalPartsManager.addPart idNameSpace, namek, glog

    pospart = PosPart.new @geometryManager, :PosPart, baseName
    pospart.parent = laylog
    pospart.child = glog
    @geometryManager.posPartsManager.addPart pospart
    pospart.exec

    if nAbs < 0
      mother = glog
      rmid  = pgonRmax[0]
      (0..(args['SideAbsName'].size - 1)).each do |i|
        alpha1 = Math::atan(args["SideAbsW"][i]/rmid)
        if alpha1 > 0
          name = (namek.to_s + args['SideAbsName'][i]).to_sym
          solidArgs = {'numSide' => 1, 'startPhi' => -alpha1, 'deltaPhi' => 2*alpha1}
          solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
          solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, name
          solid.argsInSU = solidArgs
          @geometryManager.solidsManager.addPart idNameSpace, name, solid

          materialBaseName, materialName = baseNameName(baseName, args['SideAbsMat'][i])
          log = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, name
          log.solid = solid
          log.materialBaseName = materialBaseName
          log.materialName = materialName
          @geometryManager.logicalPartsManager.addPart idNameSpace, name, log

          pospart = PosPart.new @geometryManager, :PosPart, baseName
          pospart.parent = mother
          pospart.child = log
          @geometryManager.posPartsManager.addPart pospart
          pospart.exec

          mother = log
        end
      end
    end

    return glog
  end

  def constructMidLayer(baseName, args, laylog, nm, rin, alpha)
    idNameSpace = baseName
    idName = args['MotherName'].to_sym
    name = (nm.to_s + 'Mid').to_sym
    (0..(args['AbsorbName'].size - 1)).each do |k|
      namek = (name.to_s + args['AbsorbName'][k]).to_sym
      rsi = rin + args["AbsorbD"][k]
      iin = 0
      (0..(args['RZones']-2)).each do |i|
        iin = i + 1 if rsi >= args['RMax'][i]
      end

      pgonZ = Array.new
      pgonRmin = Array.new
      pgonRmax = Array.new

      pgonZ << 0
      pgonRmin << rsi
      pgonRmax << rsi + args['AbsorbT'][k]

      pgonZ << args['ZOff'][iin] + rsi*Math::tan(args['Theta'][iin])
      pgonRmin << rsi
      pgonRmax << pgonRmax[0]

      pgonZ << args['ZOff'][iin] + pgonRmax[0]*Math::tan(args['Theta'][iin])
      pgonRmin << pgonRmax[1]
      pgonRmax << pgonRmax[1]

      solidArgs = {'numSide' => 1, 'startPhi' => -alpha, 'deltaPhi' => 2*alpha}
      solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
      solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, namek
      solid.argsInSU = solidArgs
      @geometryManager.solidsManager.addPart idNameSpace, namek, solid

      materialBaseName, materialName = baseNameName(baseName, args['AbsorbMat'][k])

      log = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, namek
      log.solid = solid
      log.materialBaseName = materialBaseName
      log.materialName = materialName
      @geometryManager.logicalPartsManager.addPart idNameSpace, namek, log

      pospart = PosPart.new @geometryManager, :PosPart, baseName
      pospart.parent = laylog
      pospart.child = log
      @geometryManager.posPartsManager.addPart pospart
      pospart.exec

      if k == 0
        rmin   = pgonRmin[0]
        rmax   = pgonRmax[0]
        mother = log
        (0..0).map do |i|
          alpha1 = Math::atan(args["MidAbsW"][i]/rmin)
          namek = (name.to_s + args['MidAbsName'][i]).to_sym

          solidArgs = {'numSide' => 1, 'startPhi' => -alpha1, 'deltaPhi' => 2*alpha1}
          solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
          solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, namek
          solid.argsInSU = solidArgs
          @geometryManager.solidsManager.addPart idNameSpace, namek, solid

          materialBaseName, materialName = baseNameName(baseName, args['MidAbsMat'][i])

          log = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, namek
          log.solid = solid
          log.materialBaseName = materialBaseName
          log.materialName = materialName
          @geometryManager.logicalPartsManager.addPart idNameSpace, namek, log

          pospart = PosPart.new @geometryManager, :PosPart, baseName
          pospart.parent = mother
          pospart.child = log
          @geometryManager.posPartsManager.addPart pospart
          pospart.exec

          mother = log
        end

        rmid = rmin + args['MiddleD']
        pgonRmin[0] = rmid
        pgonRmax[0] = rmax

        pgonZ[1] = args['ZOff'][iin] + rmid*Math::tan(args['Theta'][iin])
        pgonRmin[1] = rmid
        pgonRmax[1] = rmax
        
        pgonZ[2] = args['ZOff'][iin] + rmax*Math::tan(args['Theta'][iin])
        pgonRmin[2] = rmax
        pgonRmax[2] = rmax

        alpha1 = Math::atan(args["MiddleW"]/rmin)

        solidArgs = {'numSide' => 1, 'startPhi' => -alpha1, 'deltaPhi' => 2*alpha1}
        solidArgs["ZSection"] = pgonZ.zip(pgonRmin, pgonRmax).map {|z, rMin, rMax| {'z' => z, 'rMin' => rMin, 'rMax' => rMax }}
        solid = BasicSolid.new @geometryManager, :Polyhedra, idNameSpace, name
        solid.argsInSU = solidArgs
        @geometryManager.solidsManager.addPart idNameSpace, name, solid

        materialBaseName, materialName = baseNameName(baseName, args['MiddleMat'])

        glog = LogicalPart.new @geometryManager, :LogicalPart, idNameSpace, name
        glog.solid = solid
        glog.materialBaseName = materialBaseName
        glog.materialName = materialName
        @geometryManager.logicalPartsManager.addPart idNameSpace, name, glog

        pospart = PosPart.new @geometryManager, :PosPart, baseName
        pospart.parent = mother
        pospart.child = glog
        @geometryManager.posPartsManager.addPart pospart
        pospart.exec

      end
      return glog;
    end
  end

end

##____________________________________________________________________________||

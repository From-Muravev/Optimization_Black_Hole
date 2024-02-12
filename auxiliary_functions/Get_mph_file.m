function get_mph_file = Get_mph_file(param_optimization)
    close all
    clear
    clc
    
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    model = ModelUtil.create('Model');
    model.modelPath('~/Рабочий стол/matlab_kras/optimization_hole');
    
    comp1 = model.component.create('comp1',true);
    geom1 = comp1.geom.create('geom1', 3);
    
    wp1 = geom1.feature.create('wp1', 'WorkPlane');
    wp1.set('planetype', 'quick');
    wp1.set('quickplane', 'xy');
    
    r1 = wp1.geom.feature.create('r1', 'Rectangle');
    r1.set('size', [param_optimization(7) 0.24]);
    r1.set('pos', [0 0.01]);
    
    for r_ind = 1:19
        if param_optimization(1, r_ind) == 1
            r_name = 'r' + string(r_ind + 1);
            r_obj = wp1.geom.feature.create(r_name, 'Rectangle');
        
            r_pos = param_optimization(2)*(mod(r_ind, 18) + param_optimization(3)) + (mod(r_ind, 18) + param_optimization(4))*mod(r_ind, 18)*param_optimization(5);
            r_size = r_pos*param_optimization(6);
        
            r_obj.set('size', [r_size*0.001 0.002]);
            r_obj.set('pos', [0.002 r_pos*0.001]);
        end
    end
    geom1.run
    
    ext1 = geom1.feature.create('ext1', 'Extrude');
    ext1.set('distance', '0.06');
    ext1.selection('input').set({'wp1'});
    geom1.run;
    
    wp2 = geom1.feature.create('wp2', 'WorkPlane');
    wp2.set('planetype', 'quick');
    wp2.set('quickplane', 'yz');
    wp2.set('quickx', '0');
    
    pd = wp2.geom.feature.create('pd', 'Rectangle');
    pd.set('pos', [0, -0.001])
    pd.set('size', [0.25, 0.001])
    
    ext2 = geom1.feature.create('ext2', 'Extrude');
    ext2.selection('input').set({'wp2'});
    ext2.set('distance', '0.12');
    geom1.run;
    
    mphsave(model, 'half_tree_optimaz');
end


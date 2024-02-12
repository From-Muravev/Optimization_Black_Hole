function Export_3D(res_param)
    %% Parameters
    waveguide_width = 115/2;
    cd result/
    import com.comsol.model.*
    import com.comsol.model.util.*
    ModelUtil.clear
    
    model = ModelUtil.create('Model');
    
    comp1 = model.component.create('comp1',true);
    geom1 = comp1.geom.create('geom1', 3);
    geom1.lengthUnit('mm');
    
    wp1 = geom1.feature.create('wp1', 'WorkPlane');
    wp1.set('planetype', 'quick');
    wp1.set('quickplane', 'xy');
    
    rings = res_param{1};
    x1 = res_param{2};
    x2 = res_param{3};
    x3 = res_param{4};
    x4 = res_param{5};
    x5 = res_param{6};
    x6 = res_param{7};
    x7 = res_param{8};
    
    
    r_poses = [];
    r_sizes = [];
    for r_ind = 1:18
        if rings(r_ind) == 1
            r_name = 'r' + string(r_ind + 1);          
            r_pos = x1*(r_ind + x2) + (r_ind + x3)*r_ind*x4;
            r_size = r_pos*x5;

            r_sizes(end + 1) = r_size;
            r_poses(end + 1) = r_pos;
        else
            r_sizes(end + 1) = 0;
            r_poses(end + 1) = 0;
        end
    end

% SK: I add separate coefficient to reduce the length of the structure
   if max(r_poses) > 500
        koeff_y = 500/max(r_poses);
    else
        koeff_y = 1;
    end
    r_poses = r_poses*koeff_y;

% SK: I set koeff only to scale ABH structure along horizontal axis. If the
% with of ABH exceeds the width of the waveguide (which is fixed), it is
% scaled to have the width of 0.9*waveguide_width.
    if max(r_sizes) > waveguide_width
        koeff = 0.9*waveguide_width/max(r_sizes);
    else
        koeff = 1;
    end

    for r_ind = 1:18
        if rings(r_ind) == 1
            r_name = 'r' + string(r_ind + 1);
            r_obj = wp1.geom.feature.create(r_name, 'Rectangle');

            r_obj.set('size', [r_sizes(r_ind)*koeff x6]);
            r_obj.set('pos', [x7*koeff r_poses(r_ind)]);
        end
    end

    r1 = wp1.geom.feature.create('r1', 'Rectangle');
    r1.set('size', [x7*koeff max(r_poses) + x6]);
    r1.set('pos', [0 0]);

    geom1.run
    
    ext1 = geom1.feature.create('ext1', 'Extrude');
    ext1.set('distance', '32');
    ext1.selection('input').set({'wp1'});
    geom1.run;
    
    mphsave(model, 'optimized_model_3d');
end
function Get_res_table(res_param)
    F = 0;
    %% Parameters
    model_dimension = 2;
    params.model.axisymmetric = false;
    
    waveguide_width = 115/2;

    wave_amplitude_p0 = 1; % [Pa]
    rings = res_param{1};
    x1 = res_param{2};
    x2 = res_param{3};
    x3 = res_param{4};
    x4 = res_param{5};
    x5 = res_param{6};
    x6 = res_param{7};
    x7 = res_param{8};
    x7 = 0;
    % SK: I remove balk for simplicity

    %% Initialization of the model
    import com.comsol.model.*
    import com.comsol.model.util.*
    ModelUtil.clear
    model = ModelUtil.create('Model');
    comp1 = model.component.create('comp1', true);
    
    
    %% Set up geometry
    geom1 = comp1.geom.create('geom1', model_dimension);
    if params.model.axisymmetric
        geom1.axisymmetric(true);
    end
    geom1.lengthUnit('mm');
    
    r_poses = [];
    r_sizes = [];
    r_domains = [];
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
            r_obj = geom1.create(r_name, 'Rectangle');

            r_obj.set('size', [r_sizes(r_ind)*koeff x6]);
            r_obj.set('pos', [x7*koeff r_poses(r_ind)]);
            r_obj.set('createselection', 'on');
        end
    end

    %mphsave('debug')
    
    maximum_index_poses = find(r_poses == max(r_poses));
    maximum_index_sizes = find(r_sizes == max(r_sizes));


    % SK: I add the calculation of the strcuture length to define the
    % length of the waveguide using it.
    structure_length = max(r_poses) - min(r_poses);
    waveguide_length = structure_length*2;
    pml_length = structure_length/10;
    tube_pos_y = -waveguide_length/2 + structure_length/2;
    
    % Tube
    tube_air = geom1.create('tube_air', 'Rectangle');
    % SK: I fix the width of the waveguide here
    tube_air.set('size', [waveguide_width, waveguide_length]);
    tube_air.set('pos', [0, -waveguide_length/2 + structure_length/2]);
    tube_air.set('createselection', 'on');
    geom1.run;
    
    
    % PML: bottom
    pml_down = geom1.create('pml_down', 'Rectangle');
    pml_down.set('size', [waveguide_width, pml_length]);
    pml_down.set('pos', [0, tube_pos_y - pml_length]);
    pml_down.set('createselection', 'on');
    geom1.run;
    
    
    % PML: top
    pml_up = geom1.create('pml_up', 'Rectangle');
    pml_up.set('size', [waveguide_width, pml_length]);
    pml_up.set('pos', [0, tube_pos_y+waveguide_length]);
    pml_up.set('createselection', 'on');
    geom1.run;
    
%     r1 = geom1.create('r1', 'Rectangle');
%     r1.set('size', [x7*koeff r_poses(maximum_index_poses) + x6]);
%     r1.set('pos', [0 0]);
%     r1.set('createselection', 'on');
    % SK: I remove balk for simplicity
    
    geom1.run;

    
    %% Create selections
    % PML
    pml_up_domain_ent = mphgetselection(model.selection('geom1_pml_up_dom'));
    pml_up_domain = pml_up_domain_ent.entities;
    pml_down_domain_ent = mphgetselection(model.selection('geom1_pml_down_dom'));
    pml_down_domain = pml_down_domain_ent.entities;
    comp1.selection.create('selection_pml', 'Explicit');
    comp1.selection('selection_pml').set([pml_up_domain pml_down_domain]);
    comp1.selection('selection_pml').label('pml');
   

    % Structure
    % SK: I add selection of balk since it was not considered to be a part
    % of a structure.
%      balk_domain_ent = mphgetselection(model.selection('geom1_r1_dom'));
%      balk_domain =  balk_domain_ent.entities;
    elements2unite = {};
    idx_unite = 0;
    for r_ind = 1:18
        if rings(r_ind) == 1 
            idx_unite = idx_unite + 1;
            r_name = 'r' + string(r_ind + 1);
            elements2unite{idx_unite} = sprintf('r%i', r_ind+1);
            r_obj_domain_ent = mphgetselection(model.selection('geom1_' + r_name + '_dom'));
            r_obj_domain = r_obj_domain_ent.entities;
            try
                r_domains(idx_unite) = r_obj_domain;
            catch
                return
            end
        end
    end

%     elements2unite
        % Unite elements
    uni_elems = model.component('comp1').geom('geom1').create('uni1', 'Union');
    uni_elems.selection('input').set(elements2unite);
    uni_elems.set('intbnd', false);
    uni_elems.set('createselection', 'on');
    geom1.run;
    
    r_domains_ent = mphgetselection(model.selection('geom1_uni1_dom'));
    r_domains = r_domains_ent.entities;
%     r_domains = [balk_domain, r_domains];

    comp1.selection.create('selection_structure', 'Explicit');
    comp1.selection('selection_structure').set(r_domains);
    comp1.selection('selection_structure').label('structure');
    
    % Air domains
    tube_air_domain_ent = mphgetselection(model.selection('geom1_tube_air_dom'));
    tube_air_domain = tube_air_domain_ent.entities;
    tube_air_domain = setdiff(tube_air_domain, r_domains);
    comp1.selection.create('selection_air', 'Explicit');
    comp1.selection('selection_air').set([pml_up_domain pml_down_domain tube_air_domain]);
    comp1.selection('selection_air').label('air');
    
    % Waveguide domains
    waveguide_air_domain = setdiff(tube_air_domain, [pml_up_domain pml_down_domain]);
    comp1.selection.create('waveguide_air', 'Explicit');
    comp1.selection('waveguide_air').set(waveguide_air_domain);
    comp1.selection('waveguide_air').label('waveguide');
    % SK: I add the waveguide domain selection because background pressure
    % field should be set only for this domain.
    
            

    %% Set materials
    addpath("auxiliary_functions/")
    load_air()
    load_plastic()
    % SK: it is better to move model.component('comp1').material('mat1').selection
    % lines to the main code.
    
    
    %% Set-up physics
    % Pressure acoustics
    comp1.physics.create('acpr', 'PressureAcoustics', 'geom1');
    comp1.physics('acpr').selection.named('selection_air');
    
    comp1.physics('acpr').create('bpf1', 'BackgroundPressureField', 2);
    comp1.physics('acpr').feature('bpf1').selection.named('waveguide_air');
    % SK: make sure that BPF is applied to the correct domain
    comp1.physics('acpr').feature('bpf1').set('pamp', wave_amplitude_p0);
    comp1.physics('acpr').feature('bpf1').set('c_mat', 'from_mat');
    if params.model.axisymmetric
        comp1.physics('acpr').feature('bpf1').set('dir', [0, 0, 1]);
    else
        comp1.physics('acpr').feature('bpf1').set('dir', [0, 1, 0]);
    end
    % SK: make sure that the direction of wave propagation is correct
    
    %mphsave(model,'dd','component','on')
    % Solid mechanics
    %comp1.physics.create('solid', 'SolidMechanics', 'geom1');
    %comp1.physics('solid').selection.named('selection_structure');
    
    % Acoustic-structure boundary
    %comp1.multiphysics.create('asb1', 'AcousticStructureBoundary', 1);
    %comp1.multiphysics('asb1').selection.all;
    % SK: the above line is important since it is needed to select the
    % appropriate boundaries between solid structure and air.
    
    
    %% PML
    pml_scaling = '1';
    pml_curvature = '3';
    
    pml1 = comp1.coordSystem.create('pml1', 'PML');
    pml1.set('name', 'pml');
    if params.model.axisymmetric
        pml1.set('ScalingType', 'Cylindrical');
    end
    pml1.selection.set([pml_up_domain pml_down_domain]);
    pml1.set('PMLfactor', pml_scaling);
    pml1.set('PMLgamma', pml_curvature);
    
    
    %% Sampling points
    % SK: I've changed points since the waveguide and structure are fixed
    point_after_structure_x = waveguide_width/3;
    point_after_structure_y = max(r_poses) + structure_length/4;
    point_after_structure = geom1.create('point_after_structure', 'Point');
    point_after_structure.set('p', [point_after_structure_x; point_after_structure_y]);
    geom1.run('point_after_structure');

    %% Mesh
    freq_start = 100;
    freq_step = 1;
    freq_end = 3000;
    velocity = 343;
    wavelength_min = velocity/freq_end;
    mesh_max_element = wavelength_min/5;
    mesh_min_element = wavelength_min/20;
    mesh_curvature = 0.3;
    mesh_growth_rate = 1.5;
    mesh_pml_distribution = 10;
    mesh_narrow = 5;
    
    % Mesh size
    comp1.mesh.create('mesh1');
    comp1.mesh('mesh1').feature('size').set('custom', true);
    comp1.mesh('mesh1').feature('size').set('hmax', [num2str(mesh_max_element), '[m]']);
    comp1.mesh('mesh1').feature('size').set('hmin', [num2str(mesh_min_element), '[m]']);
    % SK: here we calculate mesh size in meters, so it has to be specified
    % when we build mesh
    comp1.mesh('mesh1').feature('size').set('hgrad', mesh_growth_rate);
    comp1.mesh('mesh1').feature('size').set('hcurve', mesh_curvature);
    comp1.mesh('mesh1').feature('size').set('hnarrow', mesh_narrow);
    % SK: please, do not forget to put the narrow resolution to make sure that
    % small elements are meshed correctly
    
    % PML
    comp1.mesh('mesh1').create('map1', 'Map');
    comp1.mesh('mesh1').feature.move('map1', 1);
    comp1.mesh('mesh1').feature('map1').selection.geom('geom1', 2);
    comp1.mesh('mesh1').feature('map1').selection.set([pml_down_domain pml_up_domain]);
    comp1.mesh('mesh1').feature('map1').selection.named('selection_pml');
    % SK: to create distribution, you should select boundaries instead of the
    % domains. Hence, you need one more selection do do it.
    pml_up_domain_bnd = mphgetselection(model.selection('geom1_pml_up_bnd'));
    pml_up_boundaries = pml_up_domain_bnd.entities;
    pml_down_domain_bnd = mphgetselection(model.selection('geom1_pml_down_bnd'));
    pml_down_boundaries = pml_down_domain_bnd.entities;
    comp1.mesh('mesh1').feature('map1').create('dis1', 'Distribution');
    comp1.mesh('mesh1').feature('map1').feature('dis1').selection.all;
    comp1.mesh('mesh1').feature('map1').feature('dis1').selection.set([pml_up_boundaries, pml_down_boundaries]);
    % SK: so, here you write selection for boundaries.
    comp1.mesh('mesh1').feature('map1').feature('dis1').set('numelem', mesh_pml_distribution);
    
%     mphsave(model,'dd','component','on')

    % Waveguide and structure
    comp1.mesh('mesh1').create('ftri1', 'FreeTri');
    comp1.mesh('mesh1').feature('ftri1').selection.geom('geom1', 2);
    comp1.mesh('mesh1').feature('ftri1').selection.set([tube_air_domain r_domains]);
    comp1.mesh('mesh1').run;
    
    
    %% Study
    f_range_std = sprintf('range(%f, %f, %f)', freq_start, freq_step, freq_end);
    model.study.create('std1');
    model.study('std1').create('freq', 'Frequency');
    model.study('std1').feature('freq').activate('acpr', true);
    model.study('std1').feature('freq').activate('solid', true);
    model.study('std1').feature('freq').set('plist', f_range_std);

    model.study('std1').run;
    
    p_t_Pa = mphinterp(model,'acpr.p_t','coord', [point_after_structure_x; point_after_structure_y]);
    p_b_Pa = mphinterp(model,'acpr.p_b','coord', [point_after_structure_x; point_after_structure_y]);
    p_dB = 20*log(abs(p_t_Pa/p_b_Pa));
    freq0 = mphglobal(model, {'acpr.freq'});
    x = mean(p_dB, 1);
    F = x(1);
    adv = transpose(p_dB);
    Table_for_plot = table(freq0, transpose(adv(1,:)));
    Table_for_plot.Properties.VariableNames = ["Частота, Гц","Коэффициент давления, дБ"];
    if ~exist('result', 'dir')
           mkdir('result')
    end
    cd result/
    writetable(Table_for_plot,'plot_data.txt');
    mphsave('optimized_model')
    cd ..
end


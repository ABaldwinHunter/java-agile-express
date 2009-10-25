package com.express.service.mapping;

import com.express.domain.*;
import com.express.service.dto.*;

public interface DomainFactory {
   
   User createUser(UserDto dto);
   
   Project createProject(ProjectDto dto, Policy policy);
   
   Iteration createIteration(IterationDto dto);
   
   BacklogItem createBacklogItem(BacklogItemDto dto);

   Theme createTheme(ThemeDto dto);

}

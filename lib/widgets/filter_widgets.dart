import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/filter_models.dart';
import '../services/app_state_service.dart';

class FilterChipWidget extends StatelessWidget {
  final FilterType filterType;
  final String displayText;
  final VoidCallback onTap;
  final bool isSelected;

  const FilterChipWidget({
    Key? key,
    required this.filterType,
    required this.displayText,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9CC53) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getFilterIcon(),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFilterIcon() {
    switch (filterType) {
      case FilterType.time:
        return const Icon(Icons.timer, size: 18);
      case FilterType.equipment:
        return const Icon(Icons.sports_soccer, size: 18);
      case FilterType.trainingStyle:
        return const Icon(Icons.fitness_center, size: 18);
      case FilterType.location:
        return const Icon(Icons.location_on, size: 18);
      case FilterType.difficulty:
        return const Icon(Icons.trending_up, size: 18);
    }
  }
}

class FilterDropdown extends StatelessWidget {
  final FilterType filterType;
  final List<String> options;
  final String title;

  const FilterDropdown({
    Key? key,
    required this.filterType,
    required this.options,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateService>(
      builder: (context, appState, child) {
        final selectedValue = _getSelectedValue(filterType, appState);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedValue,
                hint: Text('Select $title'),
                isExpanded: true,
                underline: Container(),
                onChanged: (value) => _updateFilter(filterType, value, appState),
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _getSelectedValue(FilterType filterType, AppStateService appState) {
    switch (filterType) {
      case FilterType.time:
        return appState.preferences.selectedTime;
      case FilterType.trainingStyle:
        return appState.preferences.selectedTrainingStyle;
      case FilterType.location:
        return appState.preferences.selectedLocation;
      case FilterType.difficulty:
        return appState.preferences.selectedDifficulty;
      case FilterType.equipment:
        return null;
    }
  }

  void _updateFilter(FilterType filterType, String? value, AppStateService appState) {
    switch (filterType) {
      case FilterType.time:
        appState.updateTimeFilter(value);
        break;
      case FilterType.trainingStyle:
        appState.updateTrainingStyleFilter(value);
        break;
      case FilterType.location:
        appState.updateLocationFilter(value);
        break;
      case FilterType.difficulty:
        appState.updateDifficultyFilter(value);
        break;
      case FilterType.equipment:
        break;
    }
  }
}

class EquipmentMultiSelect extends StatelessWidget {
  const EquipmentMultiSelect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateService>(
      builder: (context, appState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipment',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: FilterOptions.equipmentOptions.map((equipment) {
                final isSelected = appState.preferences.selectedEquipment.contains(equipment);
                return GestureDetector(
                  onTap: () {
                    final newSelection = Set<String>.from(appState.preferences.selectedEquipment);
                    if (isSelected) {
                      newSelection.remove(equipment);
                    } else {
                      newSelection.add(equipment);
                    }
                    appState.updateEquipmentFilter(newSelection);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF9CC53) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                        if (isSelected) const SizedBox(width: 6),
                        Text(
                          equipment,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class SkillSelector extends StatelessWidget {
  final Set<String> selectedSkills;
  final ValueChanged<Set<String>> onChanged;

  const SkillSelector({
    Key? key,
    required this.selectedSkills,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills Focus',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: SkillCategories.categories.length,
            itemBuilder: (context, index) {
              final category = SkillCategories.categories[index];
              return _buildSkillCategory(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillCategory(SkillCategory category) {
    return ExpansionTile(
      title: Text(
        category.name,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      leading: Icon(
        _getSkillIcon(category.name),
        color: _getSkillColor(category.name),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: category.subSkills.map((subSkill) {
              final isSelected = selectedSkills.contains(subSkill);
              return GestureDetector(
                onTap: () {
                  final newSelection = Set<String>.from(selectedSkills);
                  if (isSelected) {
                    newSelection.remove(subSkill);
                  } else {
                    newSelection.add(subSkill);
                  }
                  onChanged(newSelection);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF9CC53) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 14,
                        ),
                      if (isSelected) const SizedBox(width: 4),
                      Text(
                        subSkill,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getSkillColor(String skillName) {
    switch (skillName.toLowerCase()) {
      case 'passing':
        return Colors.blue;
      case 'shooting':
        return Colors.red;
      case 'dribbling':
        return Colors.green;
      case 'first touch':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSkillIcon(String skillName) {
    switch (skillName.toLowerCase()) {
      case 'passing':
        return Icons.arrow_forward;
      case 'shooting':
        return Icons.sports_soccer;
      case 'dribbling':
        return Icons.directions_run;
      case 'first touch':
        return Icons.touch_app;
      default:
        return Icons.sports;
    }
  }
}

class FilterBottomSheet extends StatelessWidget {
  final FilterType filterType;

  const FilterBottomSheet({
    Key? key,
    required this.filterType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterContent(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9CC53),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (filterType) {
      case FilterType.time:
        return FilterDropdown(
          filterType: filterType,
          options: FilterOptions.timeOptions,
          title: 'Time',
        );
      case FilterType.equipment:
        return const EquipmentMultiSelect();
      case FilterType.trainingStyle:
        return FilterDropdown(
          filterType: filterType,
          options: FilterOptions.trainingStyleOptions,
          title: 'Training Style',
        );
      case FilterType.location:
        return FilterDropdown(
          filterType: filterType,
          options: FilterOptions.locationOptions,
          title: 'Location',
        );
      case FilterType.difficulty:
        return FilterDropdown(
          filterType: filterType,
          options: FilterOptions.difficultyOptions,
          title: 'Difficulty',
        );
    }
  }
}

// Updated helper function to show filter bottom sheet
void showFilterSheet(
  BuildContext context,
  FilterType filterType,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterBottomSheet(
      filterType: filterType,
    ),
  );
} 
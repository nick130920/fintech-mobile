import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/category_model.dart';
import '../../providers/budget_setup_provider.dart';

class Step2SelectCategories extends StatelessWidget {
  const Step2SelectCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSetupProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '¿En qué gastas tu dinero?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona las categorías que más usas. Puedes agregar más después.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Botón para usar categorías por defecto
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                child: OutlinedButton.icon(
                  onPressed: provider.useDefaultCategories,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Usar categorías recomendadas'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Grid de categorías
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: provider.availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = provider.availableCategories[index];
                    final isSelected = provider.selectedCategories.contains(category);
                    
                    return _buildCategoryCard(
                      context, 
                      category, 
                      isSelected, 
                      provider,
                    );
                  },
                ),
              ),

              // Información sobre selecciones
              if (provider.selectedCategories.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, 
                          color: Colors.green[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${provider.selectedCategories.length} categorías seleccionadas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.canProceedFromStep2 
                      ? provider.proceedToStep3 
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryModel category,
    bool isSelected,
    BudgetSetupProvider provider,
  ) {
    final categoryColor = category.color;

    return GestureDetector(
      onTap: () => provider.toggleCategorySelection(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? categoryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de selección
              if (isSelected)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const SizedBox(height: 20),

              // Ícono de la categoría
              Icon(
                category.iconData,
                size: 32,
                color: isSelected ? categoryColor : Colors.grey[800],
              ),
              const SizedBox(height: 8),

              // Nombre de la categoría
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? categoryColor : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Descripción (opcional)
              if (category.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

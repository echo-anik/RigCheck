'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { buildTemplates, BuildTemplate } from '@/lib/build-templates';
import { Sparkles } from 'lucide-react';

interface TemplateSelectorProps {
  onSelectTemplate: (template: BuildTemplate) => void;
  onClose: () => void;
}

export function TemplateSelector({ onSelectTemplate, onClose }: TemplateSelectorProps) {
  const categories = [
    { id: 'enthusiast' as const, name: 'Enthusiast', color: 'bg-purple-500' },
    { id: 'gaming' as const, name: 'Gaming', color: 'bg-red-500' },
    { id: 'workstation' as const, name: 'Workstation', color: 'bg-blue-500' },
    { id: 'office' as const, name: 'Office', color: 'bg-green-500' },
    { id: 'budget' as const, name: 'Budget', color: 'bg-yellow-500' }
  ];

  const getCategoryColor = (category: BuildTemplate['category']) => {
    return categories.find(c => c.id === category)?.color || 'bg-gray-500';
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <Card className="w-full max-w-5xl max-h-[90vh] overflow-y-auto">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-2xl flex items-center gap-2">
                <Sparkles className="h-6 w-6 text-primary" />
                Choose a Build Template
              </CardTitle>
              <p className="text-muted-foreground mt-2">
                Start with a pre-configured build tailored to your needs
              </p>
            </div>
            <Button variant="ghost" onClick={onClose}>
              ✕
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {buildTemplates.map((template) => (
              <Card
                key={template.id}
                className="cursor-pointer hover:shadow-lg hover:border-primary transition-all duration-200"
                onClick={() => onSelectTemplate(template)}
              >
                <CardContent className="p-6">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-3">
                      <span className="text-4xl">{template.icon}</span>
                      <div>
                        <h3 className="font-bold text-lg">{template.name}</h3>
                        <Badge className={`${getCategoryColor(template.category)} text-white mt-1`}>
                          {categories.find(c => c.id === template.category)?.name}
                        </Badge>
                      </div>
                    </div>
                  </div>
                  
                  <p className="text-sm text-muted-foreground mb-3">
                    {template.description}
                  </p>
                  
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Budget:</span>
                      <span className="font-medium">{template.budget}</span>
                    </div>
                    
                    {template.targetSpecs.cpuCores && (
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">CPU Cores:</span>
                        <span className="font-medium">{template.targetSpecs.cpuCores}+</span>
                      </div>
                    )}
                    
                    {template.targetSpecs.ramCapacityGB && (
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">RAM:</span>
                        <span className="font-medium">{template.targetSpecs.ramCapacityGB}GB</span>
                      </div>
                    )}
                    
                    {template.targetSpecs.gpuTier && (
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">GPU Tier:</span>
                        <span className="font-medium capitalize">{template.targetSpecs.gpuTier}</span>
                      </div>
                    )}
                    
                    {template.targetSpecs.storageGB && (
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">Storage:</span>
                        <span className="font-medium">{template.targetSpecs.storageGB}GB+</span>
                      </div>
                    )}
                  </div>
                  
                  <Button className="w-full mt-4" variant="outline">
                    Use This Template
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
          
          <div className="mt-6 text-center">
            <Button variant="ghost" onClick={onClose}>
              Skip - Build from Scratch
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

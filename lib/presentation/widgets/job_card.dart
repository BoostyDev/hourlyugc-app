import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/job_model.dart';
import '../../core/utils/formatters.dart';

/// Job card widget
class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onApply,
    this.onSave,
  });

  /// Company logo with HourlyUGC fallback
  Widget _buildCompanyLogo() {
    if (job.companyLogo != null && job.companyLogo!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: job.companyLogo!,
        imageBuilder: (context, imageProvider) => Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (_, __) => _buildHourlyUGCLogo(),
        errorWidget: (_, __, ___) => _buildHourlyUGCLogo(),
      );
    }
    return _buildHourlyUGCLogo();
  }

  /// HourlyUGC branded placeholder logo
  Widget _buildHourlyUGCLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF38EF7D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: SvgPicture.asset(
            'assets/images/logo_hourlyugc.svg',
            width: 22,
            height: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and save button
              Row(
                children: [
                  // Company Logo - HourlyUGC logo as fallback
                  _buildCompanyLogo(),
                  const SizedBox(width: 12),

                  // Title and Company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.companyName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Save Button
                  if (onSave != null)
                    IconButton(
                      icon: Icon(
                        job.isSaved ? Icons.favorite : Icons.favorite_border,
                        color: job.isSaved ? Colors.red : Colors.grey,
                      ),
                      onPressed: onSave,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                job.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (job.tags != null && job.tags!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.tags!.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (job.tags != null && job.tags!.isNotEmpty)
                const SizedBox(height: 12),

              // Location and Date
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.timeAgo(job.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Budget and Apply Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.currency(job.budget),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (onApply != null)
                    FilledButton(
                      onPressed: onApply,
                      child: const Text('Apply'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

